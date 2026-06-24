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

  MenuCategory copyWith({List<MenuItem>? items}) => MenuCategory(
        id: id,
        branchId: branchId,
        name: name,
        displayName: displayName,
        isVisible: isVisible,
        sortOrder: sortOrder,
        items: items ?? this.items,
      );

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

class MenuPricingRule {
  final String id;
  final String ruleType;
  final String valueType;
  final double value;
  final String? title;
  final String? startsAt;
  final String? endsAt;
  final bool isActive;

  const MenuPricingRule({
    required this.id,
    required this.ruleType,
    required this.valueType,
    required this.value,
    this.title,
    this.startsAt,
    this.endsAt,
    this.isActive = true,
  });

  factory MenuPricingRule.fromJson(Map<String, dynamic> json) => MenuPricingRule(
        id: json['id']?.toString() ?? '',
        ruleType: json['ruleType']?.toString() ?? 'DISCOUNT',
        valueType: json['valueType']?.toString() ?? 'PERCENTAGE',
        value: _toDouble(json['value']),
        title: json['title']?.toString(),
        startsAt: json['startsAt']?.toString(),
        endsAt: json['endsAt']?.toString(),
        isActive: _toBool(json['isActive'], fallback: true),
      );

  Map<String, dynamic> toDiscountPayload() => {
        'valueType': valueType,
        'value': value,
        if (title != null && title!.isNotEmpty) 'title': title,
        if (startsAt != null && startsAt!.isNotEmpty) 'startsAt': startsAt,
        if (endsAt != null && endsAt!.isNotEmpty) 'endsAt': endsAt,
      };
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
  final List<MenuPricingRule> pricingRules;

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
    this.pricingRules = const [],
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    final categoryId = json['categoryId']?.toString() ??
        (category is Map ? category['id']?.toString() : null) ??
        '';

    return MenuItem(
      id: json['id']?.toString() ?? '',
      categoryId: categoryId,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? 'INR',
      isVisible: _toBool(json['isVisible'], fallback: true),
      isInStock: _toBool(json['isInStock'], fallback: true),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
      addons: (json['addons'] as List?)
              ?.whereType<Map>()
              .map((e) => MenuAddon.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      pricingRules: _parsePricingRules(json),
    );
  }

  MenuPricingRule? get activeDiscount {
    for (final rule in pricingRules) {
      if (rule.ruleType != 'DISCOUNT' || !rule.isActive) continue;
      return rule;
    }
    return null;
  }

  String? get discountLabel {
    final rule = activeDiscount;
    if (rule == null || rule.value <= 0) return null;
    if (rule.valueType == 'PERCENTAGE') {
      return '${rule.value.toStringAsFixed(rule.value % 1 == 0 ? 0 : 1)}% OFF';
    }
    return '₹${rule.value.toStringAsFixed(0)} OFF';
  }

  double get discountedPrice {
    final rule = activeDiscount;
    if (rule == null || rule.value <= 0) return price;
    if (rule.valueType == 'PERCENTAGE') {
      return (price * (1 - rule.value / 100)).clamp(0.0, double.infinity).toDouble();
    }
    return (price - rule.value).clamp(0.0, double.infinity).toDouble();
  }

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

List<MenuPricingRule> _parsePricingRules(Map<String, dynamic> json) {
  final raw = json['pricingRules'] ?? json['pricing_rules'];
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => MenuPricingRule.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  final inline = json['discount'];
  if (inline is Map) {
    return [
      MenuPricingRule.fromJson({
        ...Map<String, dynamic>.from(inline),
        'ruleType': 'DISCOUNT',
        'isActive': true,
      }),
    ];
  }
  return [];
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
