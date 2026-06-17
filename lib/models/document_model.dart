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
        restaurantId: json['restaurantId']?.toString() ??
            (json['restaurant'] is Map
                ? json['restaurant']['id']?.toString()
                : null) ??
            '',
        type: (json['type'] ?? json['documentType'])?.toString() ?? '',
        status: json['status']?.toString() ?? 'PENDING',
        fileUrl: (json['fileUrl'] ?? json['url'] ?? json['filePath'])?.toString(),
        rejectionReason: json['rejectionReason']?.toString(),
        expiryDate: json['expiryDate'] != null
            ? DateTime.tryParse(json['expiryDate'].toString())
            : null,
        verifiedAt: json['verifiedAt'] != null
            ? DateTime.tryParse(json['verifiedAt'].toString())
            : null,
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
                DateTime.now(),
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
