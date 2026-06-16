import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  static Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  static Future<String?> getToken() =>
      _storage.read(key: AppConstants.tokenKey);

  static Future<void> clearToken() =>
      _storage.delete(key: AppConstants.tokenKey);

  static Future<void> clear() => _storage.deleteAll();

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
