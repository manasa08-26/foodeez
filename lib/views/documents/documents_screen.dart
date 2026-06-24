import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/document_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';

const _docTypes = [
  ('PAN', 'PAN Card'),
  ('GST', 'GST Certificate'),
  ('FSSAI', 'FSSAI License'),
  ('BANK', 'Bank Statement'),
  ('REGISTRATION', 'Business Registration'),
];

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.adaptive;
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId == null) {
      return const Center(child: Text('No restaurant linked'));
    }

    final docsAsync = ref.watch(documentsProvider(restaurantId));

    return docsAsync.when(
      loading: () => const FullPageLoader(),
      error: (e, _) => ErrorView(
        message: 'Unable to load documents\n${e.toString()}',
        onRetry: () => ref.invalidate(documentsProvider(restaurantId)),
      ),
      data: (docs) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
        children: [
          Text(
            'Upload and track required restaurant verification files.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Info banner
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colors.primarySurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colors.primaryColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Documents are verified by our team. Upload clear images.',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          ..._docTypes.map((type) {
            final doc = docs.firstWhere(
              (d) => d.type == type.$1,
              orElse: () => DocumentModel(
                id: '',
                restaurantId: restaurantId,
                type: type.$1,
                status: 'NOT_UPLOADED',
                createdAt: DateTime.now(),
              ),
            );
            return _DocumentCard(
              doc: doc,
              label: type.$2,
              restaurantId: restaurantId,
              onUploaded: () => ref.invalidate(documentsProvider(restaurantId)),
            );
          }),
        ],
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentModel doc;
  final String label;
  final String restaurantId;
  final VoidCallback onUploaded;

  const _DocumentCard({
    required this.doc,
    required this.label,
    required this.restaurantId,
    required this.onUploaded,
  });

  Future<void> _pickAndUpload(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null ||
        result.files.isEmpty ||
        result.files.first.path == null) {
      return;
    }

    final ok = await ref.read(documentUploadProvider.notifier).upload(
          restaurantId,
          doc.type,
          result.files.first.path!,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Document uploaded!' : 'Upload failed'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      if (ok) onUploaded();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.adaptive;
    final uploadState = ref.watch(documentUploadProvider);
    final isUploading = uploadState.isLoading;
    final isUploaded = doc.id.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: doc.isVerified
              ? colors.successSurface.withValues(alpha: 0.4)
              : doc.isRejected
                  ? colors.errorSurface.withValues(alpha: 0.4)
                  : colors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: doc.isVerified
                  ? colors.successSurface
                  : doc.isRejected
                      ? colors.errorSurface
                      : colors.primarySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.description_outlined,
              color: doc.isVerified
                  ? AppColors.success
                  : doc.isRejected
                      ? AppColors.error
                      : colors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 15,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary)),
                const SizedBox(height: 2),
                if (isUploaded)
                  StatusBadge(status: doc.status)
                else
                  Text('Not uploaded',
                      style: TextStyle(fontSize: 12, color: colors.textHint)),
                if (doc.isRejected && doc.rejectionReason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    doc.rejectionReason!,
                    style: TextStyle(fontSize: 11, color: AppColors.error),
                  ),
                ],
              ],
            ),
          ),
          if (!doc.isVerified)
            TextButton.icon(
              onPressed:
                  isUploading ? null : () => _pickAndUpload(context, ref),
              icon: isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primary)))
                  : const Icon(Icons.upload_rounded, size: 18),
              label: Text(isUploaded ? 'Re-upload' : 'Upload'),
              style: TextButton.styleFrom(foregroundColor: colors.primaryColor),
            ),
        ],
      ),
    );
  }
}
