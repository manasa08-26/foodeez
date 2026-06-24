/// App environment — production API only.
class Env {
  /// Foodeez integration API (production).
  static const String apiBaseUrl = 'https://int.foodeez.in/api/v1';

  /// 64-char hex string = 32 bytes AES key.
  /// Must match NEXT_PUBLIC_PASSWORD_ENCRYPTION_KEY in the web .env.local
  static const String passwordEncryptionKeyHex = String.fromEnvironment(
    'PASSWORD_KEY',
    defaultValue:
        '4f3e2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f',
  );

  /// Set ENCRYPT_PASSWORD=true at build time if the backend requires AES passwords.
  static const bool encryptPassword = bool.fromEnvironment(
    'ENCRYPT_PASSWORD',
    defaultValue: false,
  );

  static const bool isProduction = true;
}
