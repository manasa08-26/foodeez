class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String branchId;
  final String restaurantId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String paymentMethod;
  final String? paymentStatus;
  final String? specialInstructions;
  final String? deliveryAddress;
  final String? rejectionReason;
  final int? prepTimeMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.branchId,
    required this.restaurantId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    this.paymentStatus,
    this.specialInstructions,
    this.deliveryAddress,
    this.rejectionReason,
    this.prepTimeMinutes,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id']?.toString() ?? '',
        orderNumber: json['orderNumber']?.toString() ?? json['id'].toString(),
        status: json['status']?.toString() ?? 'PLACED',
        customerId: json['customerId']?.toString(),
        customerName: (json['customerName'] ??
            json['customer']?['name'] ??
            json['customer']?['displayName'])
            ?.toString(),
        customerPhone:
            (json['customerPhone'] ?? json['customer']?['phone'])?.toString(),
        branchId: json['branchId']?.toString() ?? '',
        restaurantId: json['restaurantId']?.toString() ?? '',
        items: (json['items'] as List?)
                ?.whereType<Map>()
                .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
        subtotal: _toDouble(json['subtotal']),
        deliveryFee: _toDouble(json['deliveryFee']),
        discount: _toDouble(json['discount']),
        total: _toDouble(json['total'] ?? json['totalAmount']),
        paymentMethod: json['paymentMethod']?.toString() ?? 'COD',
        paymentStatus: json['paymentStatus']?.toString(),
        specialInstructions: json['specialInstructions']?.toString(),
        deliveryAddress: json['deliveryAddress'] is String
            ? json['deliveryAddress']
            : json['deliveryAddress']?['addressLine1']?.toString(),
        rejectionReason: json['rejectionReason']?.toString(),
        prepTimeMinutes: _toInt(json['prepTimeMinutes']),
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );

  bool get isPending => status == 'PLACED';
  bool get isActive =>
      ['PLACED', 'ACCEPTED', 'PREPARING'].contains(status);

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'status': status,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'branchId': branchId,
        'restaurantId': restaurantId,
        'totalAmount': total,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final double total;
  final List<String> addons;

  OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.addons = const [],
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id']?.toString() ?? '',
        menuItemId: json['menuItemId']?.toString() ?? '',
        name: (json['name'] ?? json['menuItem']?['name'])?.toString() ?? '',
        quantity: _toInt(json['quantity'], fallback: 1),
        price: _toDouble(json['price']),
        total: _toDouble(json['total']),
        addons: (json['addons'] as List?)?.map((e) => e.toString()).toList() ??
            [],
      );
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
