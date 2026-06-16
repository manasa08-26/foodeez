import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final restaurantId =
        data['restaurantId']?.toString() ?? data['id']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.checklist_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            const Text('Onboarding Progress',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          if (restaurantName.isNotEmpty)
            Text(restaurantName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.primarySurface,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('$pct%',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.primary)),
          ]),
          const SizedBox(height: 6),
          Text(
            '$pct% complete${leadStatus.isNotEmpty ? ' · $leadStatus' : ''}',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12),
          ),
          if (progress < 1.0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white),
                onPressed: () {
                  if (restaurantId != null) {
                    context.go('/restaurant/onboarding');
                  }
                },
                child: const Text('Continue Onboarding'),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
