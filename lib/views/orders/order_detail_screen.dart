import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  final _rejectionCtrl = TextEditingController();
  bool _isUpdating = false;

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      await ref
          .read(orderServiceProvider)
          .updateOrderStatus(widget.orderId, status);
      ref.invalidate(orderDetailProvider(widget.orderId));
      ref.invalidate(ordersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated to $status')),
        );
      }
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
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailProvider(widget.orderId));

    return orderAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (order) => LoadingOverlay(
          isLoading: _isUpdating,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderHeader(order: order),
                const SizedBox(height: 16),
                _CustomerInfo(order: order),
                const SizedBox(height: 16),
                _ItemsList(order: order),
                const SizedBox(height: 16),
                _PriceSummary(order: order),
                const SizedBox(height: 16),
                _StatusActions(
                  order: order,
                  onUpdateStatus: _updateStatus,
                  rejectionCtrl: _rejectionCtrl,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final OrderModel order;
  const _OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    final heroText = Colors.white;
    final heroSubtext = Colors.white.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.orderNumber}',
                style: TextStyle(
                  color: heroText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.dateTime(order.createdAt),
            style: TextStyle(color: heroSubtext, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.paymentMethod(order.paymentMethod),
            style: TextStyle(color: heroSubtext, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _CustomerInfo extends StatelessWidget {
  final OrderModel order;
  const _CustomerInfo({required this.order});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Customer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.customerName != null)
            _InfoRow(Icons.person_outline, order.customerName!),
          if (order.customerPhone != null)
            _InfoRow(Icons.phone_outlined, order.customerPhone!),
          if (order.deliveryAddress != null)
            _InfoRow(Icons.location_on_outlined, order.deliveryAddress!),
          if (order.specialInstructions != null &&
              order.specialInstructions!.isNotEmpty)
            _InfoRow(Icons.note_outlined, order.specialInstructions!),
        ],
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final OrderModel order;
  const _ItemsList({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    return _Card(
      title: 'Items (${order.items.length})',
      child: Column(
        children: order.items
            .map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors.primarySurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '×${item.quantity}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(item.name,
                              style: const TextStyle(fontSize: 14))),
                      Text(AppFormatters.currency(item.total),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final OrderModel order;
  const _PriceSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Bill Summary',
      child: Column(
        children: [
          _PriceRow('Subtotal', AppFormatters.currency(order.subtotal)),
          _PriceRow('Delivery Fee', AppFormatters.currency(order.deliveryFee)),
          if (order.discount > 0)
            _PriceRow('Discount', '-${AppFormatters.currency(order.discount)}',
                color: AppColors.success),
          const Divider(height: 16),
          _PriceRow('Total', AppFormatters.currency(order.total), isBold: true),
        ],
      ),
    );
  }
}

class _StatusActions extends StatelessWidget {
  final OrderModel order;
  final Future<void> Function(String) onUpdateStatus;
  final TextEditingController rejectionCtrl;

  const _StatusActions({
    required this.order,
    required this.onUpdateStatus,
    required this.rejectionCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final status = order.status.toUpperCase();
    final banner = _bannerFor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (banner != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: banner.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: banner.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        switch (status) {
          'PLACED' => Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reject Order',
                    isDanger: true,
                    isOutlined: true,
                    onPressed: () async {
                      final confirmed = await showConfirmationDialog(
                        context,
                        title: 'Reject Order',
                        message:
                            'Are you sure you want to reject this order?',
                        confirmLabel: 'Reject',
                        isDanger: true,
                      );
                      if (confirmed == true) {
                        onUpdateStatus('CANCELLED');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Accept Order',
                    icon: Icons.check_circle_outline,
                    onPressed: () => onUpdateStatus('CONFIRMED'),
                  ),
                ),
              ],
            ),
          'CONFIRMED' => Column(
              children: [
                AppButton(
                  label: 'Start Preparing',
                  width: double.infinity,
                  icon: Icons.restaurant_rounded,
                  onPressed: () => onUpdateStatus('PREPARING'),
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Cancel Order',
                  width: double.infinity,
                  isDanger: true,
                  isOutlined: true,
                  onPressed: () async {
                    final confirmed = await showConfirmationDialog(
                      context,
                      title: 'Cancel Order',
                      message: 'Cancel this confirmed order?',
                      confirmLabel: 'Cancel Order',
                      isDanger: true,
                    );
                    if (confirmed == true) {
                      onUpdateStatus('CANCELLED');
                    }
                  },
                ),
              ],
            ),
          'PREPARING' => AppButton(
              label: 'Mark Ready for Pickup',
              width: double.infinity,
              icon: Icons.check_circle_outline,
              onPressed: () => onUpdateStatus('READY_FOR_PICKUP'),
            ),
          _ => const SizedBox.shrink(),
        },
      ],
    );
  }

  _OrderBanner? _bannerFor(String status) => switch (status) {
        'PLACED' => const _OrderBanner(
            title: 'New order awaiting your confirmation',
            subtitle:
                'Accept to start preparation or reject if you cannot fulfill it.',
            bg: Color(0x14F59E0B),
            border: Color(0x59F59E0B),
          ),
        'CONFIRMED' => const _OrderBanner(
            title: 'Order confirmed — ready to start cooking?',
            subtitle: 'Tap "Start Preparing" when the kitchen begins work.',
            bg: Color(0x1438BDF8),
            border: Color(0x4D38BDF8),
          ),
        'PREPARING' => const _OrderBanner(
            title: 'Kitchen is preparing this order',
            subtitle:
                'Tap "Mark Ready for Pickup" once the food is packed.',
            bg: Color(0x148B5CF6),
            border: Color(0x4D8B5CF6),
          ),
        'READY_FOR_PICKUP' => const _OrderBanner(
            title: 'Food is ready — waiting for delivery partner',
            subtitle: 'A delivery partner will pick up the order shortly.',
            bg: Color(0x1410B981),
            border: Color(0x4D10B981),
          ),
        _ => null,
      };
}

class _OrderBanner {
  final String title;
  final String subtitle;
  final Color bg;
  final Color border;
  const _OrderBanner({
    required this.title,
    required this.subtitle,
    required this.bg,
    required this.border,
  });
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryColor)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;
  const _PriceRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 15 : 13,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color:
          color ?? (isBold ? AppColors.textPrimary : AppColors.textSecondary),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }
}
