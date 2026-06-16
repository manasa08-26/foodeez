class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String role;
  final String? restaurantId;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.restaurantId,
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        displayName: json['displayName'] ?? json['display_name'] ?? '',
        role: json['role'] ?? '',
        restaurantId: json['restaurantId']?.toString(),
        isActive: json['isActive'] ?? json['is_active'] ?? true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role,
        'restaurantId': restaurantId,
        'isActive': isActive,
      };
}

class AuthUser {
  final String token;
  final String role;
  final String email;
  final String displayName;
  final String? restaurantId;

  AuthUser({
    required this.token,
    required this.role,
    required this.email,
    required this.displayName,
    this.restaurantId,
  });
}
