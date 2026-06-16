class DocumentModel {
  final String id;
  final String restaurantId;
  final String type;
  final String status;
  final String? fileUrl;
  final String? rejectionReason;
  final DateTime? expiryDate;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  DocumentModel({
    required this.id,
    required this.restaurantId,
    required this.type,
    required this.status,
    this.fileUrl,
    this.rejectionReason,
    this.expiryDate,
    this.verifiedAt,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['id']?.toString() ?? '',
        restaurantId: json['restaurantId']?.toString() ?? '',
        type: json['type'] ?? '',
        status: json['status'] ?? 'PENDING',
        fileUrl: json['fileUrl'],
        rejectionReason: json['rejectionReason'],
        expiryDate: json['expiryDate'] != null
            ? DateTime.tryParse(json['expiryDate'])
            : null,
        verifiedAt: json['verifiedAt'] != null
            ? DateTime.tryParse(json['verifiedAt'])
            : null,
        createdAt:
            DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  String get displayType => switch (type) {
        'PAN' => 'PAN Card',
        'GST' => 'GST Certificate',
        'FSSAI' => 'FSSAI License',
        'BANK' => 'Bank Statement',
        'REGISTRATION' => 'Business Registration',
        _ => type,
      };

  bool get isVerified => status == 'VERIFIED';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';
}
