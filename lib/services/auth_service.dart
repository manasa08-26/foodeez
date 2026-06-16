import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/env.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../core/utils/crypto_utils.dart';
import '../core/utils/jwt_utils.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<AuthUser> login(String email, String password) async {
    try {
      // Encryption is toggled by Env.encryptPassword (default: false).
      // The existing Foodeez mobile app sends plain text — most backends
      // accept plain text from mobile. Pass --dart-define=ENCRYPT_PASSWORD=true
      // to enable AES-CBC encryption if required.
      final String passwordPayload = Env.encryptPassword
          ? CryptoUtils.encryptPassword(password)
          : password;

      if (kDebugMode) {
        debugPrint('[AuthService] login endpoint: ${ApiEndpoints.login}');
        debugPrint('[AuthService] encryption enabled: ${Env.encryptPassword}');
        debugPrint('[AuthService] email: $email');
        debugPrint(
            '[AuthService] password payload (first 10 chars): ${passwordPayload.substring(0, passwordPayload.length.clamp(0, 10))}...');
      }
      final res = await _dio.post(ApiEndpoints.login, data: {
        'email': email,
        'password': passwordPayload,
      });

      final token = res.data['accessToken'] as String;

      // ── Role gate ────────────────────────────────────────────────────────────
      // Decode JWT first to check the role BEFORE persisting anything.
      final payload = JwtUtils.decode(token) ?? {};
      final userMap = res.data['user'] as Map<String, dynamic>? ?? {};
      final role = (payload['role'] ?? userMap['role'] ?? '').toString();

      debugPrint(
          '[AuthService] JWT role=$role restaurantId=${payload['restaurantId']}');

      if (role != AppConstants.roleRestaurantAdmin) {
        // Do NOT save the token — this app is only for restaurant admins.
        throw ApiException(
          'Access denied. This app is only for Restaurant Admins.\n'
          'Please use the correct portal for your role.',
          statusCode: 403,
        );
      }
      // ─────────────────────────────────────────────────────────────────────────

      await LocalStorage.saveToken(token);
      debugPrint('[AuthService] login: saved token len=${token.length}');

      return AuthUser(
        token: token,
        role: role,
        email: userMap['email'] ?? email,
        displayName: userMap['displayName'] ?? userMap['email'] ?? email,
        restaurantId:
            (payload['restaurantId'] ?? userMap['restaurantId'])?.toString(),
      );
    } on DioException catch (e) {
      // Log full response for debugging
      // ignore: avoid_print
      print(
          '[Login Error] status=${e.response?.statusCode} body=${e.response?.data}');
      debugPrint('[AuthService] login error status=${e.response?.statusCode}');
      throw ApiException.fromDioError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final res = await _dio.get(ApiEndpoints.me);
      if (kDebugMode) debugPrint('[AuthService] getMe response: ${res.data}');
      return UserModel.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post(ApiEndpoints.passwordReset, data: {'email': email});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> confirmPasswordReset(String token, String newPassword) async {
    try {
      await _dio.post(ApiEndpoints.passwordResetConfirm, data: {
        'token': token,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    await LocalStorage.clearToken();
  }

  Future<AuthUser?> getStoredUser() async {
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) return null;
    if (JwtUtils.isExpired(token)) {
      await LocalStorage.clearToken();
      return null;
    }
    final payload = JwtUtils.decode(token);
    if (payload == null) return null;

    // Reject stored sessions that belong to a non-restaurant_admin role.
    final storedRole = (payload['role'] ?? '').toString();
    if (storedRole != AppConstants.roleRestaurantAdmin) {
      await LocalStorage.clearToken();
      return null;
    }

    return AuthUser(
      token: token,
      role: storedRole,
      email: payload['email'] ?? '',
      displayName: (payload['displayName']?.toString() ?? '').isNotEmpty
          ? payload['displayName'].toString()
          : (payload['email']?.toString() ?? ''),
      restaurantId: payload['restaurantId']?.toString(),
    );
  }
}
