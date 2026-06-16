class MenuCategory {
  final String id;
  final String branchId;
  final String name;
  final String? displayName;
  final bool isVisible;
  final int sortOrder;
  final List<MenuItem> items;

  MenuCategory({
    required this.id,
    required this.branchId,
    required this.name,
    this.displayName,
    this.isVisible = true,
    this.sortOrder = 0,
    this.items = const [],
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['id']?.toString() ?? '',
        branchId: json['branchId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        displayName: json['displayName']?.toString(),
        isVisible: _toBool(json['isVisible'], fallback: true),
        sortOrder: _toInt(json['sortOrder']),
        items: (json['items'] as List?)
                ?.whereType<Map>()
                .map((e) => MenuItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
      );

  int get visibleItemCount => items.where((i) => i.isVisible).length;
}

class MenuItem {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final bool isVisible;
  final bool isInStock;
  final String? imageUrl;
  final List<MenuAddon> addons;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'INR',
    this.isVisible = true,
    this.isInStock = true,
    this.imageUrl,
    this.addons = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id']?.toString() ?? '',
        categoryId: json['categoryId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        price: _toDouble(json['price']),
        currency: json['currency']?.toString() ?? 'INR',
        isVisible: _toBool(json['isVisible'], fallback: true),
        isInStock: _toBool(json['isInStock'], fallback: true),
        imageUrl: json['imageUrl']?.toString(),
        addons: (json['addons'] as List?)
                ?.whereType<Map>()
                .map((e) => MenuAddon.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'currency': currency,
        'isVisible': isVisible,
        'isInStock': isInStock,
      };
}

class MenuAddon {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;

  MenuAddon({
    required this.id,
    required this.name,
    required this.price,
    this.isAvailable = true,
  });

  factory MenuAddon.fromJson(Map<String, dynamic> json) => MenuAddon(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        price: _toDouble(json['price']),
        isAvailable: _toBool(json['isAvailable'], fallback: true),
      );
}

class MenuChangeRequest {
  final String id;
  final String menuItemId;
  final String itemName;
  final String status;
  final Map<String, dynamic> changes;
  final DateTime createdAt;

  MenuChangeRequest({
    required this.id,
    required this.menuItemId,
    required this.itemName,
    required this.status,
    required this.changes,
    required this.createdAt,
  });

  factory MenuChangeRequest.fromJson(Map<String, dynamic> json) =>
      MenuChangeRequest(
        id: json['id']?.toString() ?? '',
        menuItemId: json['menuItemId']?.toString() ?? '',
        itemName: json['itemName']?.toString() ?? '',
        status: json['status']?.toString() ?? 'PENDING',
        changes: json['changes'] is Map
            ? Map<String, dynamic>.from(json['changes'])
            : {},
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
                DateTime.now(),
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

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().toLowerCase();
  if (['true', '1', 'yes'].contains(normalized)) return true;
  if (['false', '0', 'no'].contains(normalized)) return false;
  return fallback;
}
