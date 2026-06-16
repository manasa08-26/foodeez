import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/menu_model.dart';

final menuServiceProvider = Provider<MenuService>((ref) {
  return MenuService(ref.read(dioProvider));
});

class MenuService {
  final Dio _dio;
  MenuService(this._dio);

  Future<List<MenuCategory>> getCategories(String branchId) async {
    try {
      final res = await _dio.get(ApiEndpoints.menuCategories(branchId));
      final list = _toList(res.data);
      return list.map((e) => MenuCategory.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MenuCategory> createCategory(
      String branchId, Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(
          ApiEndpoints.menuCategories(branchId), data: data);
      return MenuCategory.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MenuCategory> updateCategory(
      String categoryId, Map<String, dynamic> data) async {
    try {
      final res =
          await _dio.patch(ApiEndpoints.menuCategory(categoryId), data: data);
      return MenuCategory.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MenuItem> createMenuItem(
      String branchId, Map<String, dynamic> data) async {
    try {
      final res =
          await _dio.post(ApiEndpoints.menuItems(branchId), data: data);
      return MenuItem.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<MenuItem> updateMenuItem(
      String itemId, Map<String, dynamic> data) async {
    try {
      final res =
          await _dio.patch(ApiEndpoints.menuItem(itemId), data: data);
      return MenuItem.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> toggleItemVisibility(String itemId, bool isVisible) async {
    await updateMenuItem(itemId, {'isVisible': isVisible});
  }

  Future<void> toggleItemStock(String itemId, bool isInStock) async {
    await updateMenuItem(itemId, {'isInStock': isInStock});
  }

  Future<MenuAddon> addAddon(
      String itemId, Map<String, dynamic> data) async {
    try {
      final res =
          await _dio.post(ApiEndpoints.menuItemAddons(itemId), data: data);
      return MenuAddon.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> bulkUpload(String branchId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      await _dio.post(ApiEndpoints.menuBulkUpload(branchId),
          data: formData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  static List _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['categories', 'data', 'items', 'results']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }
}
