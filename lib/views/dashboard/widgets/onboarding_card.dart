import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingCard extends StatelessWidget {
  const OnboardingCard({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
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
          Row(children: [
            const Icon(Icons.checklist_rounded,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            const Text('Onboarding Progress',
                style: TextStyle(
                    fontSize: 16,
                    letterSpacing: -0.25,
                    fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 12),
          if (restaurantName.isNotEmpty)
            Text(restaurantName,
                style: const TextStyle(
                    fontSize: 15,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: AppColors.primarySurface,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$pct%',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: AppColors.primary)),
          ]),
          const SizedBox(height: 6),
          Text(
            '$pct% complete${leadStatus.isNotEmpty ? ' · $leadStatus' : ''}',
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
          // if (progress < 1.0) ...[
          //   const SizedBox(height: 12),
          //   SizedBox(
          //     width: double.infinity,
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //           backgroundColor: AppColors.primary,
          //           foregroundColor: Colors.white),
          //       onPressed: () {
          //         if (restaurantId != null) {
          //           context.go('/restaurant/onboarding');
          //         }
          //       },
          //       child: const Text('Continue Onboarding'),
          //     ),
          //   ),
          // ],
        ]),
      ),
    );
  }
}
