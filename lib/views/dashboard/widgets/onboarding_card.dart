import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingCard extends StatelessWidget {
  const OnboardingCard({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    double progress = 0.0;
    if (data['onboardingProgress'] is num) {
      progress = (data['onboardingProgress'] as num) / 100.0;
    } else if (data['onboardingStep'] is num) {
      progress = (data['onboardingStep'] as num) / 5.0;
    } else if (data['onboardingCompletedSteps'] != null &&
        data['onboardingTotalSteps'] != null) {
      final completed = (data['onboardingCompletedSteps'] as num).toDouble();
      final total = (data['onboardingTotalSteps'] as num).toDouble();
      progress = total > 0 ? completed / total : 0.0;
    }
    progress = progress.clamp(0.0, 1.0);

    final pct = (progress * 100).toStringAsFixed(0);
    final leadStatus = data['leadStatus']?.toString() ?? '';
    final restaurantName =
        data['restaurantName']?.toString() ?? data['name']?.toString() ?? '';
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
          Row(children: [
            Icon(Icons.checklist_rounded, color: colors.primaryColor, size: 18),
            const SizedBox(width: 8),
            Text('Onboarding Progress',
                style: TextStyle(
                    fontSize: 16,
                    letterSpacing: -0.25,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary)),
          ]),
          const SizedBox(height: 12),
          if (restaurantName.isNotEmpty)
            Text(restaurantName,
                style: TextStyle(
                    fontSize: 15,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: colors.primarySurface,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$pct%',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: colors.primaryColor)),
          ]),
          const SizedBox(height: 6),
          Text(
            '$pct% complete${leadStatus.isNotEmpty ? ' · $leadStatus' : ''}',
            style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ]),
      ),
    );
  }
}
