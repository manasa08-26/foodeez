import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class BranchControlsScreen extends ConsumerStatefulWidget {
  final String branchId;
  const BranchControlsScreen({super.key, required this.branchId});

  @override
  ConsumerState<BranchControlsScreen> createState() =>
      _BranchControlsScreenState();
}

class _BranchControlsScreenState extends ConsumerState<BranchControlsScreen> {
  final _openCtrl = TextEditingController();
  final _closeCtrl = TextEditingController();
  bool _isOnline = false;
  bool _busyMode = false;
  bool _temporaryClosure = false;
  bool _populated = false;

  void _populate(dynamic branch) {
    if (!_populated) {
      _openCtrl.text = branch.openingTime ?? '';
      _closeCtrl.text = branch.closingTime ?? '';
      _isOnline = branch.isOnline;
      _busyMode = branch.busyMode;
      _temporaryClosure = branch.temporaryClosure;
      _populated = true;
    }
  }

  Future<void> _save(String restaurantId) async {
    final ok = await ref.read(branchControlsProvider.notifier).updateControls(
      restaurantId,
      widget.branchId,
      {
        'openingTime': _openCtrl.text.trim(),
        'closingTime': _closeCtrl.text.trim(),
        'isOnline': _isOnline,
        'busyMode': _busyMode,
        'temporaryClosure': _temporaryClosure,
      },
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Controls updated!' : 'Update failed'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (ok) ref.invalidate(branchProvider((restaurantId, widget.branchId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId = ref.watch(restaurantIdProvider) ?? '';
    final branchAsync =
        ref.watch(branchProvider((restaurantId, widget.branchId)));
    final controlsState = ref.watch(branchControlsProvider);
    final isControlsLoading = controlsState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      //appBar: AppBar(title: const Text('Branch Controls')),
      body: branchAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (branch) {
          _populate(branch);
          return LoadingOverlay(
            isLoading: isControlsLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Toggles
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                        const SizedBox(height: 12),
                        _ToggleRow(
                          title: 'Online',
                          subtitle: 'Accept new orders',
                          value: _isOnline,
                          activeThumbColor: AppColors.success,
                          onChanged: (v) => setState(() => _isOnline = v),
                        ),
                        const Divider(height: 16),
                        _ToggleRow(
                          title: 'Busy Mode',
                          subtitle: 'Pause delivery, only pickup',
                          value: _busyMode,
                          activeThumbColor: AppColors.warning,
                          onChanged: (v) => setState(() => _busyMode = v),
                        ),
                        const Divider(height: 16),
                        _ToggleRow(
                          title: 'Temporary Closure',
                          subtitle: 'Temporarily close this branch',
                          value: _temporaryClosure,
                          activeThumbColor: AppColors.error,
                          onChanged: (v) =>
                              setState(() => _temporaryClosure = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Hours
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Operating Hours',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Opening',
                                controller: _openCtrl,
                                prefixIcon: const Icon(Icons.wb_sunny_outlined,
                                    color: AppColors.textHint, size: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                label: 'Closing',
                                controller: _closeCtrl,
                                prefixIcon: const Icon(
                                    Icons.nightlight_outlined,
                                    color: AppColors.textHint,
                                    size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Save Changes',
                    width: double.infinity,
                    isLoading: isControlsLoading,
                    onPressed: () => _save(restaurantId),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Color activeThumbColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeThumbColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: activeThumbColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
