import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/loading_overlay.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId == null) {
      return const Center(child: Text('No restaurant linked'));
    }

    final onboardingAsync = ref.watch(onboardingProvider(restaurantId));

    return onboardingAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (status) {
          final steps = [
            _Step('Business Registration', 'Provide business details & documents', status.step1Complete),
            _Step('Document Verification', 'Upload and verify required documents', status.step2Complete),
            _Step('Branch Setup', 'Add your restaurant branch(es)', status.step3Complete),
            _Step('Menu Setup', 'Add menu categories and items', status.step4Complete),
            _Step('Activation', 'Go live and start accepting orders', status.step5Complete),
          ];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Onboarding Progress',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${status.completedSteps}/5',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: status.completedSteps / 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(status.completedSteps / 5 * 100).round()}% complete',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Steps',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...steps.asMap().entries.map(
                      (e) => _StepCard(
                        step: e.key + 1,
                        data: e.value,
                        isCurrent: e.key + 1 == status.currentStep,
                      ),
                    ),
              ],
            ),
          );
        },
    );
  }
}

class _Step {
  final String title;
  final String description;
  final bool isComplete;
  _Step(this.title, this.description, this.isComplete);
}

class _StepCard extends StatelessWidget {
  final int step;
  final _Step data;
  final bool isCurrent;

  const _StepCard(
      {required this.step, required this.data, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final isComplete = data.isComplete;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary
              : isComplete
                  ? AppColors.success
                  : AppColors.cardBorder,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.successSurface
                  : isCurrent
                      ? AppColors.primarySurface
                      : AppColors.background,
              shape: BoxShape.circle,
            ),
            child: isComplete
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 22)
                : Center(
                    child: Text(
                      step.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isComplete
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.primary
                            : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.description,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (isCurrent && !isComplete)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Current',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
