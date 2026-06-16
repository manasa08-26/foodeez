import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_model.dart';
import '../models/dashboard_model.dart';
import '../models/user_model.dart';
import '../services/restaurant_service.dart';

// Dashboard — typed metrics (used by chart widgets)
final dashboardProvider =
    FutureProvider.autoDispose<DashboardMetrics>((ref) async {
  return ref.read(restaurantServiceProvider).getDashboard();
});

// Dashboard — raw JSON map (used by the live dashboard UI for flexible field access)
final rawDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(restaurantServiceProvider).getRawDashboard();
});

// Restaurant detail
final restaurantProvider =
    FutureProvider.autoDispose.family<RestaurantModel, String>((ref, id) async {
  return ref.read(restaurantServiceProvider).getRestaurant(id);
});

// Onboarding
final onboardingProvider =
    FutureProvider.autoDispose.family<OnboardingStatus, String>(
        (ref, restaurantId) async {
  return ref.read(restaurantServiceProvider).getOnboarding(restaurantId);
});

// Restaurant users
final restaurantUsersProvider =
    FutureProvider.autoDispose.family<List<UserModel>, String>(
        (ref, restaurantId) async {
  return ref.read(restaurantServiceProvider).getRestaurantUsers(restaurantId);
});

// Restaurant update controller — Riverpod 3.x Notifier
class RestaurantUpdateState {
  final bool isLoading;
  final RestaurantModel? data;
  final String? error;
  const RestaurantUpdateState(
      {this.isLoading = false, this.data, this.error});
}

class RestaurantUpdateNotifier extends Notifier<RestaurantUpdateState> {
  @override
  RestaurantUpdateState build() => const RestaurantUpdateState();

  Future<bool> update(String id, Map<String, dynamic> data) async {
    state = const RestaurantUpdateState(isLoading: true);
    try {
      final updated =
          await ref.read(restaurantServiceProvider).updateRestaurant(id, data);
      state = RestaurantUpdateState(data: updated);
      return true;
    } catch (e) {
      state = RestaurantUpdateState(error: e.toString());
      return false;
    }
  }
}

final restaurantUpdateProvider =
    NotifierProvider.autoDispose<RestaurantUpdateNotifier, RestaurantUpdateState>(
  RestaurantUpdateNotifier.new,
);
