import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static bool isExpired(String token) {
    final payload = decode(token);
    if (payload == null) return true;
    final exp = payload['exp'];
    if (exp == null) return false;
    final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expiry);
  }

  static String? getRole(String token) => decode(token)?['role'] as String?;
  static String? getEmail(String token) => decode(token)?['email'] as String?;
  static String? getDisplayName(String token) =>
      decode(token)?['displayName'] as String?;
  static String? getRestaurantId(String token) =>
      decode(token)?['restaurantId']?.toString();
}
