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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
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
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Live Orders',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                      fontSize: 17)),
            ]),
            Row(children: [
              if (ordersLoading)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary)),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero),
              ),
            ]),
          ]),
          const SizedBox(height: 10),
          if (activeOrders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No active orders right now',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
              ),
            )
          else
            ...activeOrders.map((o) => _OrderTile(order: o)),
          if (activeOrders.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go('/orders'),
                child: const Text('View all orders →'),
              ),
            ),
        ]),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final Map<String, dynamic> order;

  @override
  Widget build(BuildContext context) {
    final id = order['id']?.toString() ?? order['orderId']?.toString() ?? '—';
    final status = order['status']?.toString() ?? 'unknown';
    final amount = order['totalAmount'] ?? order['amount'] ?? 0;
    final customerName = order['customerName'] ??
        (order['customer'] is Map
            ? order['customer']['name']
            : order['customer']) ??
        'Customer';
    final placedAt =
        order['placedAt']?.toString() ?? order['createdAt']?.toString() ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go('/orders/$id'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  '#${id.length > 8 ? id.substring(0, 8) : id} · $customerName',
                  style: const TextStyle(
                      fontSize: 13.5,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w800)),
              if (placedAt.isNotEmpty)
                Text(_formatTime(placedAt),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(status: status),
            const SizedBox(height: 4),
            Text('₹ $amount',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: -0.2)),
          ]),
        ]),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return iso;
    }
  }
}
