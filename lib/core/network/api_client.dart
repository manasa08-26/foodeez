import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl, // reads from --dart-define at runtime
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await LocalStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint(
              '[Dio] onRequest: token present, url=${options.uri}');
        } else {
          debugPrint('[Dio] onRequest: no token, url=${options.uri}');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          debugPrint(
              '[Dio] onError 401: clearing token url=${error.requestOptions.uri}');
          await LocalStorage.clearToken();
          // Navigation handled in router redirect
        } else {
          debugPrint(
              '[Dio] onError type=${error.type} status=${error.response?.statusCode} url=${error.requestOptions.uri} message=${error.message}');
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  factory ApiException.fromDioError(DioException e) {
    final data = e.response?.data;
    String msg = 'Something went wrong';
    if (data is Map && data['message'] != null) {
      final m = data['message'];
      msg = m is List ? m.first.toString() : m.toString();
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      msg =
          'Connection timed out. Check internet and API URL (${e.requestOptions.uri.origin}).';
    } else if (e.type == DioExceptionType.connectionError) {
      msg =
          'Cannot reach the server (${e.requestOptions.uri.origin}). Check internet or VPN.';
    }
    return ApiException(msg, statusCode: e.response?.statusCode);
  }
}
