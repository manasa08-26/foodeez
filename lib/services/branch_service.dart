import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/branch_model.dart';

final branchServiceProvider = Provider<BranchService>((ref) {
  return BranchService(ref.read(dioProvider));
});

class BranchService {
  final Dio _dio;
  BranchService(this._dio);

  Future<List<BranchModel>> getBranches(String restaurantId) async {
    try {
      final res = await _dio.get(ApiEndpoints.branches(restaurantId));
      final list = _toList(res.data);
      return list.map((e) => BranchModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<BranchModel> getBranch(
      String restaurantId, String branchId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.branch(restaurantId, branchId));
      return BranchModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<BranchModel> createBranch(
      String restaurantId, Map<String, dynamic> data) async {
    try {
      final res =
          await _dio.post(ApiEndpoints.branches(restaurantId), data: data);
      return BranchModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<BranchModel> updateBranch(
      String restaurantId, String branchId, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch(
          ApiEndpoints.branch(restaurantId, branchId),
          data: data);
      return BranchModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<BranchModel> toggleOnline(
      String restaurantId, String branchId, bool isOnline) async {
    return updateBranch(restaurantId, branchId, {'isOnline': isOnline});
  }

  Future<BranchModel> updateControls(String restaurantId, String branchId,
      Map<String, dynamic> controls) async {
    return updateBranch(restaurantId, branchId, controls);
  }

  static List _toList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in ['branches', 'data', 'items', 'results']) {
        if (data[key] is List) return data[key] as List;
      }
    }
    return [];
  }
}
