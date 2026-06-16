import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import '../constants/env.dart';

/// Matches the web app's encryptPassword() in lib/crypto.ts exactly:
///
///   const key = CryptoJS.enc.Hex.parse(keyHex);      // hex → bytes
///   const iv  = CryptoJS.lib.WordArray.random(16);   // random 16 bytes
///   AES-CBC + PKCS7
///   return `${ivBase64}:${cipherBase64}`;             // "iv:cipher"
class CryptoUtils {
  static final _rng = Random.secure();

  /// Converts a 64-char hex string into 32 raw bytes (same as CryptoJS.enc.Hex.parse).
  static Uint8List _hexToBytes(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  /// Generates n random bytes (same as CryptoJS.lib.WordArray.random(n)).
  static Uint8List _randomBytes(int n) {
    return Uint8List.fromList(
      List<int>.generate(n, (_) => _rng.nextInt(256)),
    );
  }

  static String encryptPassword(String password) {
    try {
      final keyBytes = _hexToBytes(Env.passwordEncryptionKeyHex);
      final ivBytes = _randomBytes(16);

      final key = enc.Key(keyBytes);
      final iv = enc.IV(ivBytes);

      final encrypter = enc.Encrypter(
        enc.AES(key, mode: enc.AESMode.cbc, padding: 'PKCS7'),
      );

      final encrypted = encrypter.encrypt(password, iv: iv);

      // Web output: "${ivBase64}:${cipherBase64}"
      final ivBase64 = base64.encode(ivBytes);
      final cipherBase64 = encrypted.base64; // already base64

      return '$ivBase64:$cipherBase64';
    } catch (e) {
      // If encryption fails, return password as-is so the API gives a clear error
      return password;
    }
  }
}
