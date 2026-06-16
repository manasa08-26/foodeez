class RestaurantModel {
  final String id;
  final String name;
  final String? legalEntityName;
  final String? ownerName;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? gstNumber;
  final String? fssaiNumber;
  final String? panNumber;
  final String? bankName;
  final String? bankAccountHolderName;
  final String? bankAccountNumber;
  final String? ifscCode;
  final String? accountType;
  final String? brandDescription;
  final List<String> cuisineTags;
  final double? serviceRadiusKm;
  final double? latitude;
  final double? longitude;
  final String? coverPhotoUrl;
  final String status;
  final DateTime? createdAt;

  RestaurantModel({
    required this.id,
    required this.name,
    this.legalEntityName,
    this.ownerName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.gstNumber,
    this.fssaiNumber,
    this.panNumber,
    this.bankName,
    this.bankAccountHolderName,
    this.bankAccountNumber,
    this.ifscCode,
    this.accountType,
    this.brandDescription,
    this.cuisineTags = const [],
    this.serviceRadiusKm,
    this.latitude,
    this.longitude,
    this.coverPhotoUrl,
    this.status = 'active',
    this.createdAt,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      RestaurantModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        legalEntityName: json['legalEntityName']?.toString(),
        ownerName: json['ownerName']?.toString(),
        email: json['email']?.toString(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        city: json['city']?.toString(),
        state: json['state']?.toString(),
        zipCode: json['zipCode']?.toString(),
        gstNumber: json['gstNumber']?.toString(),
        fssaiNumber: json['fssaiNumber']?.toString(),
        panNumber: json['panNumber']?.toString(),
        bankName: json['bankName']?.toString(),
        bankAccountHolderName: json['bankAccountHolderName']?.toString(),
        bankAccountNumber: json['bankAccountNumber']?.toString(),
        ifscCode: json['ifscCode']?.toString(),
        accountType: json['accountType']?.toString(),
        brandDescription: json['brandDescription']?.toString(),
        cuisineTags: (json['cuisineTags'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        serviceRadiusKm: _toDouble(json['serviceRadiusKm']),
        latitude: _toDouble(json['latitude']),
        longitude: _toDouble(json['longitude']),
        coverPhotoUrl: json['coverPhotoUrl']?.toString(),
        status: json['status']?.toString() ?? 'active',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
      );
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

class OnboardingStatus {
  final String restaurantId;
  final int currentStep;
  final bool step1Complete;
  final bool step2Complete;
  final bool step3Complete;
  final bool step4Complete;
  final bool step5Complete;

  OnboardingStatus({
    required this.restaurantId,
    required this.currentStep,
    required this.step1Complete,
    required this.step2Complete,
    required this.step3Complete,
    required this.step4Complete,
    required this.step5Complete,
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) =>
      OnboardingStatus(
        restaurantId: json['restaurantId']?.toString() ?? '',
        currentStep: json['currentStep'] ?? 1,
        step1Complete: json['step1Complete'] ?? false,
        step2Complete: json['step2Complete'] ?? false,
        step3Complete: json['step3Complete'] ?? false,
        step4Complete: json['step4Complete'] ?? false,
        step5Complete: json['step5Complete'] ?? false,
      );

  int get completedSteps => [
        step1Complete,
        step2Complete,
        step3Complete,
        step4Complete,
        step5Complete,
      ].where((s) => s).length;
}
