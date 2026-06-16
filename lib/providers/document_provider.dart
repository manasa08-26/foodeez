import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

final documentsProvider =
    FutureProvider.autoDispose.family<List<DocumentModel>, String>(
        (ref, restaurantId) async {
  return ref.read(documentServiceProvider).getDocuments(restaurantId);
});

class DocumentUploadState {
  final bool isLoading;
  final DocumentModel? data;
  final String? error;
  const DocumentUploadState({this.isLoading = false, this.data, this.error});
}

class DocumentUploadNotifier extends Notifier<DocumentUploadState> {
  @override
  DocumentUploadState build() => const DocumentUploadState();

  Future<bool> upload(
      String restaurantId, String type, String filePath) async {
    state = const DocumentUploadState(isLoading: true);
    try {
      final doc = await ref
          .read(documentServiceProvider)
          .uploadDocument(restaurantId, type, filePath);
      state = DocumentUploadState(data: doc);
      return true;
    } catch (e) {
      state = DocumentUploadState(error: e.toString());
      return false;
    }
  }
}

final documentUploadProvider =
    NotifierProvider.autoDispose<DocumentUploadNotifier, DocumentUploadState>(
  DocumentUploadNotifier.new,
);
