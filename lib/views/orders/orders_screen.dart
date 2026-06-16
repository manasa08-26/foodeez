import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/order_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';

const _statuses = [
  ('All', null),
  ('Placed', 'PLACED'),
  ('Accepted', 'ACCEPTED'),
  ('Preparing', 'PREPARING'),
  ('Ready', 'READY'),
  ('Delivered', 'DELIVERED'),
  ('Cancelled', 'CANCELLED'),
];

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(orderFilterProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          // Status filter chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  backgroundColor: AppColors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
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
                      color: AppColors.primary,
                      onRefresh: () => ref.refresh(ordersProvider.future),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final order = orders[i];
                          return GestureDetector(
                            onTap: () =>
                                context.go('/orders/${order.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: order.isPending
                                      ? AppColors.warning
                                      : AppColors.cardBorder,
                                  width: order.isPending ? 2 : 1,
                                ),
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
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            if (order.customerName != null)
                                              Text(
                                                order.customerName!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.textSecondary,
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
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary),
                                            ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        AppFormatters.currency(order.total),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.access_time_rounded,
                                          size: 12,
                                          color: AppColors.textHint),
                                      const SizedBox(width: 4),
                                      Text(
                                        timeago.format(order.createdAt),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textHint),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.textHint,
                                          size: 18),
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
      ),
    );
  }
}
