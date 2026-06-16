import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/document_model.dart';

final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService(ref.read(dioProvider));
});

class DocumentService {
  final Dio _dio;
  DocumentService(this._dio);

  Future<List<DocumentModel>> getDocuments(String restaurantId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.restaurantDocuments(restaurantId));
      final list = (res.data as List?) ?? [];
      return list.map((e) => DocumentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<DocumentModel> uploadDocument(
      String restaurantId, String type, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        'file': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(
          ApiEndpoints.restaurantDocuments(restaurantId),
          data: formData);
      return DocumentModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
