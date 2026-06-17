import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/status_badge.dart';

class KdsScreen extends ConsumerStatefulWidget {
  const KdsScreen({super.key});

  @override
  ConsumerState<KdsScreen> createState() => _KdsScreenState();
}

class _KdsScreenState extends ConsumerState<KdsScreen> {
  io.Socket? _socket;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _connectSocket();
    _startPolling();
  }

  Future<void> _connectSocket() async {
    final token = await LocalStorage.getToken();
    if (token == null) return;

    final wsUrl = AppConstants.baseUrl.replaceFirst('/api/v1', '');
    _socket = io.io(
      '$wsUrl/ws/partner/orders/live',
      io.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
          {'Authorization': 'Bearer $token'}).build(),
    );

    _socket!.onConnect((_) {
      final restaurantId = ref.read(restaurantIdProvider);
      if (restaurantId != null) {
        _socket!.emit('join-restaurant-room', restaurantId);
      }
    });

    _socket!.on('new-order', (data) {
      try {
        final order = OrderModel.fromJson(data as Map<String, dynamic>);
        ref.read(liveOrdersProvider.notifier).addOrder(order);
        _playAlert();
      } catch (_) {}
    });

    _socket!.on('order-cancelled', (data) {
      ref.read(liveOrdersProvider.notifier).fetchOrders();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(AppConstants.kdsPollingInterval, (_) {
      ref.read(liveOrdersProvider.notifier).fetchOrders();
    });
  }

  void _playAlert() {
    // audioplayers would be used here in a real implementation
  }

  @override
  void dispose() {
    _socket?.disconnect();
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kdsState = ref.watch(liveOrdersProvider);
    final activeOrders = kdsState.orders
        .where((o) => ['PLACED', 'ACCEPTED', 'PREPARING'].contains(o.status))
        .toList();
    final readyOrders =
        kdsState.orders.where((o) => o.status == 'READY').toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: kdsState.isLoading && kdsState.orders.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.textPrimary)),
            )
          : kdsState.orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restaurant_menu,
                          color: AppColors.cardBorder, size: 64),
                      const SizedBox(height: 16),
                      const Text('No active orders',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text('New orders will appear here',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    if (activeOrders.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'ACTIVE ORDERS',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _KdsOrderCard(order: activeOrders[i]),
                            childCount: activeOrders.length,
                          ),
                        ),
                      ),
                    ],
                    if (readyOrders.isNotEmpty) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Text(
                            'READY FOR PICKUP',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => _KdsOrderCard(
                                order: readyOrders[i], isDone: true),
                            childCount: readyOrders.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _KdsOrderCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final bool isDone;
  const _KdsOrderCard({required this.order, this.isDone = false});

  @override
  ConsumerState<_KdsOrderCard> createState() => _KdsOrderCardState();
}

class _KdsOrderCardState extends ConsumerState<_KdsOrderCard> {
  int _prepTime = 15;

  // KDS amber/kitchen palette per order status
  Color get _borderColor => switch (widget.order.status) {
        'PLACED' => AppColors.statusPlaced,
        'ACCEPTED' => AppColors.statusAccepted,
        'PREPARING' => AppColors.statusPreparing,
        'READY' => AppColors.statusReady,
        _ => Colors.white24,
      };

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _borderColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.orderNumber}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                StatusBadge(status: order.status, fontSize: 11),
              ],
            ),
          ),
          // Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (order.customerName != null)
                    Text(
                      order.customerName!,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}×',
                              style: TextStyle(
                                color: _borderColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Spacer(),
                  Text(
                    AppFormatters.currency(order.total),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Actions
          if (!widget.isDone) _buildActions(order),
        ],
      ),
    );
  }

  Widget _buildActions(OrderModel order) {
    if (order.status == 'PLACED') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          children: [
            // Prep time selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Prep:',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
                const SizedBox(width: 4),
                ...[10, 15, 20, 30].map(
                  (t) => GestureDetector(
                    onTap: () => setState(() => _prepTime = t),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            _prepTime == t ? AppColors.primary : Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${t}m',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _KdsBtn(
                    label: 'Reject',
                    color: AppColors.error,
                    onTap: () async {
                      await ref
                          .read(liveOrdersProvider.notifier)
                          .reject(order.id, 'Restaurant busy');
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _KdsBtn(
                    label: 'Accept',
                    color: AppColors.success,
                    onTap: () async {
                      await ref
                          .read(liveOrdersProvider.notifier)
                          .accept(order.id, _prepTime);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (order.status == 'ACCEPTED' || order.status == 'PREPARING') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: _KdsBtn(
          label: '✓ Ready',
          color: AppColors.success,
          onTap: () async {
            await ref.read(liveOrdersProvider.notifier).markReady(order.id);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _KdsBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _KdsBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
