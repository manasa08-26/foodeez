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
    final colors = context.adaptive;
    final numVal = (value is num)
        ? value as num
        : (int.tryParse(value?.toString() ?? '') ?? 0);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlight ? AppColors.warning : colors.cardBorder,
          width: highlight ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: highlight ? 22 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(children: [
          if (icon != null)
            Container(
              decoration: BoxDecoration(
                color: colors.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: colors.primaryColor, size: 21),
            ),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                    letterSpacing: 0.7,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11),
              ),
              const SizedBox(height: 6),
              Text(
                numVal.toString(),
                style: TextStyle(
                    fontSize: 29,
                    height: 1,
                    letterSpacing: -0.9,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
