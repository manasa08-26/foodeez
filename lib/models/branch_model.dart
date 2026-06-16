class BranchModel {
  final String id;
  final String restaurantId;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? openingTime;
  final String? closingTime;
  final double? latitude;
  final double? longitude;
  final bool isOnline;
  final bool busyMode;
  final bool temporaryClosure;
  final DateTime? createdAt;

  BranchModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.openingTime,
    this.closingTime,
    this.latitude,
    this.longitude,
    this.isOnline = false,
    this.busyMode = false,
    this.temporaryClosure = false,
    this.createdAt,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        id: json['id']?.toString() ?? '',
        restaurantId: json['restaurantId']?.toString() ??
            (json['restaurant'] is Map
                ? json['restaurant']['id']?.toString()
                : null) ??
            '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString(),
        city: json['city']?.toString(),
        state: json['state']?.toString(),
        zipCode: json['zipCode']?.toString(),
        openingTime: json['openingTime']?.toString(),
        closingTime: json['closingTime']?.toString(),
        latitude: _toDouble(json['latitude']),
        longitude: _toDouble(json['longitude']),
        isOnline: _toBool(json['isOnline']),
        busyMode: _toBool(json['busyMode']),
        temporaryClosure: _toBool(json['temporaryClosure']),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      );

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  BranchModel copyWith({
    bool? isOnline,
    bool? busyMode,
    bool? temporaryClosure,
    String? openingTime,
    String? closingTime,
  }) =>
      BranchModel(
        id: id,
        restaurantId: restaurantId,
        name: name,
        address: address,
        city: city,
        state: state,
        zipCode: zipCode,
        openingTime: openingTime ?? this.openingTime,
        closingTime: closingTime ?? this.closingTime,
        latitude: latitude,
        longitude: longitude,
        isOnline: isOnline ?? this.isOnline,
        busyMode: busyMode ?? this.busyMode,
        temporaryClosure: temporaryClosure ?? this.temporaryClosure,
        createdAt: createdAt,
      );
}
