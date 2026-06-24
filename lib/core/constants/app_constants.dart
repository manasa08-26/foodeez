import 'env.dart';

class AppConstants {
  AppConstants._();

  // API — https://int.foodeez.in/api/v1 (see lib/core/constants/env.dart)
  static String get baseUrl => Env.apiBaseUrl;
  static const String tokenKey = 'restaurant_onboarding_token';
  static String get encryptionKeyHex => Env.passwordEncryptionKeyHex;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // KDS
  static const Duration kdsPollingInterval = Duration(seconds: 10);
  static const int orderAutoRejectSeconds = 90;

  // Splash
  static const Duration splashDuration = Duration(seconds: 5);

  // Allowed roles for this app
  static const String roleRestaurantAdmin = 'restaurant_admin';
  static const String roleRestaurantOwner = 'restaurant_owner';
  static const String roleRestaurantManager = 'restaurant_manager';
  static const String roleRestaurantStaff = 'restaurant_staff';

  static const List<String> restaurantRoles = [
    roleRestaurantAdmin,
    roleRestaurantOwner,
    roleRestaurantManager,
    roleRestaurantStaff,
  ];
}

class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String passwordReset = '/auth/password-reset';
  static const String passwordResetConfirm = '/auth/password-reset/confirm';

  // Restaurant users
  static String restaurantUsers(String restaurantId) =>
      '/restaurants/$restaurantId/users';

  // Restaurant
  static String restaurant(String id) => '/restaurants/$id';
  static String restaurantOnboarding(String id) =>
      '/restaurants/$id/onboarding';
  static String restaurantDocuments(String id) => '/restaurants/$id/documents';
  static String restaurantDocument(String id, String docId) =>
      '/restaurants/$id/documents/$docId';

  // Branches
  static String branches(String restaurantId) =>
      '/restaurants/$restaurantId/branches';
  static String branch(String restaurantId, String branchId) =>
      '/restaurants/$restaurantId/branches/$branchId';
  static String branchControls(String restaurantId, String branchId) =>
      '/restaurants/$restaurantId/branches/$branchId';

  // Menu
  static String menuCategories(String branchId) =>
      '/branches/$branchId/menu-categories';
  static String menuCategory(String categoryId) =>
      '/menu-categories/$categoryId';
  static String menuItems(String branchId) => '/branches/$branchId/menu-items';
  static String menuItem(String itemId) => '/menu-items/$itemId';
  static String menuItemAddons(String itemId) => '/menu-items/$itemId/addons';
  static String menuBulkUpload(String branchId) =>
      '/branches/$branchId/menu-bulk-upload';
  static String menuScan(String branchId) => '/branches/$branchId/menu-scan';
  static String menuChangeRequests(String branchId) =>
      '/branches/$branchId/change-requests';

  // Orders
  static const String restaurantOrders = '/restaurant/orders';
  static String restaurantOrder(String orderId) =>
      '/restaurant/orders/$orderId';
  static String restaurantOrderStatus(String orderId) =>
      '/restaurant/orders/$orderId/status';

  // Partner orders (KDS)
  static const String partnerOrders = '/partner/orders';
  static String partnerOrderAccept(String orderId) =>
      '/partner/orders/$orderId/accept';
  static String partnerOrderReject(String orderId) =>
      '/partner/orders/$orderId/reject';
  static String partnerOrderReady(String orderId) =>
      '/partner/orders/$orderId/ready';

  // Settlement
  static const String settlementToday = '/partner/settlement/today';
  static const String settlementTodayOrders =
      '/partner/settlement/today/orders';
  static String settlementSummary(String period) =>
      '/partner/settlement/$period';
  static String settlementOrders(String period) =>
      '/partner/settlement/$period/orders';
  static const String settlementRecentPayouts =
      '/partner/settlement/payouts';
  static const String settlementWithdraw = '/partner/settlement/withdraw';

  // Dashboard
  static const String dashboard = '/dashboard';
}
