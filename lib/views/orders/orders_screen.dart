import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';

const _statuses = [
  ('All', null),
  ('Placed', 'PLACED'),
  ('Confirmed', 'CONFIRMED'),
  ('Preparing', 'PREPARING'),
  ('Ready', 'READY_FOR_PICKUP'),
  ('Delivered', 'DELIVERED'),
  ('Cancelled', 'CANCELLED'),
];

const _quickActions = <String, List<({String label, String next})>>{
  'PLACED': [
    (label: 'Accept', next: 'CONFIRMED'),
    (label: 'Reject', next: 'CANCELLED'),
  ],
  'CONFIRMED': [
    (label: 'Preparing', next: 'PREPARING'),
  ],
  'PREPARING': [
    (label: 'Ready ✓', next: 'READY_FOR_PICKUP'),
  ],
};

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final colors = context.adaptive;

    return Column(
      children: [
          // Status filter chips
          SizedBox(
            height: 54,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              scrollDirection: Axis.horizontal,
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (label, status) = _statuses[i];
                final isSelected = filter.status == status;
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => ref
                      .read(orderFilterProvider.notifier)
                      .update((s) => s.copyWith(
                          status: status, clearStatus: status == null)),
                  selectedColor: colors.primaryColor,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : colors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                  backgroundColor: colors.surface,
                  side: BorderSide(
                    color: isSelected ? colors.primaryColor : colors.cardBorder,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ordersAsync.when(
              loading: () => const FullPageLoader(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(ordersProvider),
              ),
              data: (orders) => orders.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No orders found',
                      subtitle: 'Orders will appear here when received',
                    )
                  : RefreshIndicator(
                      color: colors.primaryColor,
                      onRefresh: () => ref.refresh(ordersProvider.future),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final order = orders[i];
                          return GestureDetector(
                            onTap: () => context.go('/orders/${order.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(17),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: order.isPending
                                      ? AppColors.warning
                                      : colors.cardBorder,
                                  width: order.isPending ? 1.4 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.cardShadow,
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '#${order.orderNumber}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.15,
                                                letterSpacing: -0.35,
                                                fontWeight: FontWeight.w900,
                                                color: colors.textPrimary,
                                              ),
                                            ),
                                            if (order.customerName != null)
                                              Text(
                                                order.customerName!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textSecondary,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(status: order.status),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    children: order.items
                                        .take(3)
                                        .map((item) => Text(
                                              '${item.name} ×${item.quantity}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textSecondary),
                                            ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  _OrderQuickActions(
                                    orderId: order.id,
                                    status: order.status,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        AppFormatters.currency(order.total),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                          color: colors.primaryColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.access_time_rounded,
                                          size: 12, color: colors.textHint),
                                      const SizedBox(width: 4),
                                      Text(
                                        timeago.format(order.createdAt),
                                        style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: colors.textHint),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right_rounded,
                                          color: colors.textHint, size: 18),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
    );
  }
}

class _OrderQuickActions extends ConsumerStatefulWidget {
  const _OrderQuickActions({
    required this.orderId,
    required this.status,
  });

  final String orderId;
  final String status;

  @override
  ConsumerState<_OrderQuickActions> createState() =>
      _OrderQuickActionsState();
}

class _OrderQuickActionsState extends ConsumerState<_OrderQuickActions> {
  String? _busy;

  Future<void> _run(String nextStatus) async {
    setState(() => _busy = nextStatus);
    try {
      await ref
          .read(orderServiceProvider)
          .updateOrderStatus(widget.orderId, nextStatus);
      ref.invalidate(ordersProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = _quickActions[widget.status.toUpperCase()];
    if (actions == null || actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) {
        final isBusy = _busy == action.next;
        final isDanger = action.next == 'CANCELLED';
        return TextButton(
          onPressed: isBusy ? null : () => _run(action.next),
          style: TextButton.styleFrom(
            backgroundColor: isDanger
                ? AppColors.error.withValues(alpha: 0.12)
                : AppColors.success.withValues(alpha: 0.12),
            foregroundColor: isDanger ? AppColors.error : AppColors.success,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isBusy ? 'Updating…' : action.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        );
      }).toList(),
    );
  }
}
