import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = _resolve(status.toUpperCase());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: -0.1,
          height: 1,
        ),
      ),
    );
  }

  (Color, Color, String) _resolve(String s) => switch (s) {
        'PLACED' => (AppColors.statusPlaced, AppColors.infoSurface, 'Placed'),
        'CONFIRMED' => (
            AppColors.statusPlaced,
            AppColors.infoSurface,
            'Confirmed'
          ),
        'ACCEPTED' => (
            AppColors.statusAccepted,
            AppColors.accentLight,
            'Accepted'
          ),
        'PREPARING' => (
            AppColors.statusPreparing,
            AppColors.warningSurface,
            'Preparing'
          ),
        'READY' => (AppColors.statusReady, AppColors.successSurface, 'Ready'),
        'READY_FOR_PICKUP' => (
            AppColors.statusReady,
            AppColors.successSurface,
            'Ready for Pickup'
          ),
        'PICKED_UP' => (
            AppColors.statusDelivering,
            const Color(0xFFCFFAFE),
            'Picked Up'
          ),
        'ON_THE_WAY' => (
            AppColors.statusDelivering,
            const Color(0xFFCFFAFE),
            'On the Way'
          ),
        'OUT_FOR_DELIVERY' => (
            AppColors.statusDelivering,
            const Color(0xFFCFFAFE),
            'Out for Delivery'
          ),
        'DELIVERED' => (
            AppColors.statusDelivered,
            AppColors.successSurface,
            'Delivered'
          ),
        'CANCELLED' => (
            AppColors.statusCancelled,
            AppColors.errorSurface,
            'Cancelled'
          ),
        'VERIFIED' => (AppColors.success, AppColors.successSurface, 'Verified'),
        'PENDING' => (AppColors.warning, AppColors.warningSurface, 'Pending'),
        'REJECTED' => (AppColors.error, AppColors.errorSurface, 'Rejected'),
        'ACTIVE' => (AppColors.success, AppColors.successSurface, 'Active'),
        'INACTIVE' => (AppColors.textSecondary, AppColors.border, 'Inactive'),
        _ => (AppColors.textSecondary, AppColors.border, s),
      };
}
