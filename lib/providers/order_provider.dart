import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

// Filter state for orders
class OrderFilter {
  final String? status;
  final int page;
  OrderFilter({this.status, this.page = 1});

  OrderFilter copyWith(
          {String? status, int? page, bool clearStatus = false}) =>
      OrderFilter(
        status: clearStatus ? null : (status ?? this.status),
        page: page ?? this.page,
      );
}

final orderFilterProvider =
    StateProvider.autoDispose<OrderFilter>((ref) => OrderFilter());

final ordersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final filter = ref.watch(orderFilterProvider);
  return ref.read(orderServiceProvider).getOrders(
        status: filter.status,
        page: filter.page,
      );
});

final orderDetailProvider =
    FutureProvider.autoDispose.family<OrderModel, String>((ref, orderId) async {
  return ref.read(orderServiceProvider).getOrder(orderId);
});

// KDS live orders
class KdsState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;

  const KdsState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  KdsState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
  }) =>
      KdsState(
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class KdsNotifier extends Notifier<KdsState> {
  @override
  KdsState build() {
    fetchOrders();
    return const KdsState();
  }

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await ref.read(orderServiceProvider).getLiveOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addOrder(OrderModel order) {
    final existing = state.orders.any((o) => o.id == order.id);
    if (!existing) {
      state = state.copyWith(orders: [order, ...state.orders]);
    }
  }

  Future<bool> accept(String orderId, int prepTimeMinutes) async {
    try {
      final updated =
          await ref.read(orderServiceProvider).acceptOrder(orderId, prepTimeMinutes);
      _updateOrder(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reject(String orderId, String reason) async {
    try {
      final updated =
          await ref.read(orderServiceProvider).rejectOrder(orderId, reason);
      _updateOrder(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markReady(String orderId) async {
    try {
      final updated = await ref.read(orderServiceProvider).markReady(orderId);
      _updateOrder(updated);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _updateOrder(OrderModel updated) {
    final newOrders =
        state.orders.map((o) => o.id == updated.id ? updated : o).toList();
    state = state.copyWith(orders: newOrders);
  }
}

final liveOrdersProvider =
    NotifierProvider.autoDispose<KdsNotifier, KdsState>(KdsNotifier.new);
