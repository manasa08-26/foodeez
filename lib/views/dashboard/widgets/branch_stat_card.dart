import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class BranchStatCard extends StatelessWidget {
  const BranchStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.highlight = false,
  });

  final String label;
  final dynamic value;
  final IconData? icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final numVal =
        (value is num) ? value as num : (int.tryParse(value?.toString() ?? '') ?? 0);
    return Card(
      shape: highlight
          ? RoundedRectangleBorder(
              side: BorderSide(color: AppColors.warning, width: 2),
              borderRadius: BorderRadius.circular(12))
          : null,
      elevation: highlight ? 6 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          if (icon != null)
            Container(
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: AppColors.primary),
            ),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                    fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                numVal.toString(),
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
