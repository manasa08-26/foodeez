/// ─────────────────────────────────────────────
///  HOW TO SWITCH ENVIRONMENTS
///
///  PRODUCTION (default — used when you just run normally):
///    defaultValue is set to https://int.foodeez.in/api/v1
///    Just do:  flutter run
///
///  LOCAL DEV (Android emulator):
///    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001/api/v1
///
///  LOCAL DEV (iOS simulator / real device on same WiFi):
///    flutter run --dart-define=API_BASE_URL=http://192.168.x.x:3001/api/v1
///
///  VS Code: select a launch config from .vscode/launch.json
///  Android Studio: Edit Configuration → Additional run args → --dart-define=...
/// ─────────────────────────────────────────────
class Env {
  /// Production URL  → https://int.foodeez.in/api/v1
  /// Local emulator  → http://10.0.2.2:3001/api/v1
  /// Local simulator → http://localhost:3001/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://int.foodeez.in/api/v1', // ← PRODUCTION (default)
  );

  /// 64-char hex string = 32 bytes AES key.
  /// Must match NEXT_PUBLIC_PASSWORD_ENCRYPTION_KEY in the web .env.local
  static const String passwordEncryptionKeyHex = String.fromEnvironment(
    'PASSWORD_KEY',
    defaultValue: '4f3e2a1b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f',
  );

  /// ─────────────────────────────────────────────────────────────────
  ///  PASSWORD ENCRYPTION TOGGLE
  ///
  ///  The web app (Next.js) encrypts passwords with AES before sending.
  ///  The existing Foodeez mobile app skeleton sends plain text.
  ///  Set this to false if the backend accepts plain-text passwords
  ///  from mobile clients (most production backends do).
  ///
  ///  To force encryption:
  ///    flutter run --dart-define=ENCRYPT_PASSWORD=true
  /// ─────────────────────────────────────────────────────────────────
  static const bool encryptPassword = bool.fromEnvironment(
    'ENCRYPT_PASSWORD',
    defaultValue: false, // ← plain text (matches existing mobile app behaviour)
  );

  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: true, // true when no --dart-define override
  );
}
