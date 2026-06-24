import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/status_badge.dart';

class LiveOrdersCard extends StatelessWidget {
  const LiveOrdersCard({
    super.key,
    required this.activeOrders,
    required this.ordersLoading,
    required this.onRefresh,
  });

  final List<Map<String, dynamic>> activeOrders;
  final bool ordersLoading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Live Orders',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      fontSize: 17,
                      color: colors.textPrimary)),
            ]),
            Row(children: [
              if (ordersLoading)
                SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: colors.primaryColor)),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                    foregroundColor: colors.primaryColor,
                    padding: EdgeInsets.zero),
              ),
            ]),
          ]),
          const SizedBox(height: 10),
          if (activeOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No active orders right now',
                    style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
            )
          else
            ...activeOrders.take(5).map((order) {
              final id = order['id']?.toString() ?? '';
              final number = order['orderNumber']?.toString() ?? '--';
              final status = order['status']?.toString() ?? 'PLACED';
              final total = order['total'] ?? order['grandTotal'] ?? 0;
              return InkWell(
                onTap: id.isNotEmpty ? () => context.go('/orders/$id') : null,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('#$number',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: colors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('₹$total',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textSecondary)),
                          ]),
                    ),
                    StatusBadge(status: status),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: colors.textHint, size: 18),
                  ]),
                ),
              );
            }),
        ]),
      ),
    );
  }
}
