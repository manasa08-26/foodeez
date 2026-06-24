import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// App-wide switch with green ON state in dark mode.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.onColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  /// Optional semantic ON color in light mode (e.g. warning, error).
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.success,
        activeThumbColor: AppColors.white,
        inactiveTrackColor: AppColors.darkCardBorder,
        inactiveThumbColor: AppColors.darkTextHint,
      );
    }

    if (onColor != null) {
      return Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: onColor,
        activeTrackColor: onColor!.withValues(alpha: 0.35),
      );
    }

    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
    );
  }
}
