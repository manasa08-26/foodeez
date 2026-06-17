import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId == null) {
      return const Scaffold(body: Center(child: Text('No restaurant linked')));
    }

    final branchesAsync = ref.watch(branchesProvider(restaurantId));

    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(title: const Text('Branches')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/branches/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Branch'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      body: branchesAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(branchesProvider(restaurantId)),
        ),
        data: (branches) => branches.isEmpty
            ? EmptyState(
                icon: Icons.store_mall_directory_rounded,
                title: 'No branches yet',
                subtitle: 'Add your first branch to get started',
                actionLabel: 'Add Branch',
                onAction: () => context.go('/branches/new'),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.refresh(branchesProvider(restaurantId).future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
                  itemCount: branches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final b = branches[i];
                    return GestureDetector(
                      onTap: () => context.go('/branches/${b.id}'),
                      child: Container(
                        padding: const EdgeInsets.all(17),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.store_mall_directory_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.15,
                                          letterSpacing: -0.35,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      if (b.city != null)
                                        Text(
                                          [b.city, b.state]
                                              .where((e) => e != null)
                                              .join(', '),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                StatusBadge(
                                    status: b.isOnline ? 'ACTIVE' : 'INACTIVE'),
                              ],
                            ),
                            if (b.openingTime != null || b.closingTime != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 14,
                                        color: AppColors.textSecondary),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${b.openingTime ?? ''} – ${b.closingTime ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _Action(Icons.menu_book_rounded, 'Menu',
                                    () => context.go('/branches/${b.id}/menu')),
                                const SizedBox(width: 8),
                                _Action(
                                    Icons.tune_rounded,
                                    'Controls',
                                    () => context
                                        .go('/branches/${b.id}/controls')),
                                const Spacer(),
                                _OnlineToggle(b: b, restaurantId: restaurantId),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Action(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _OnlineToggle extends ConsumerWidget {
  final dynamic b;
  final String restaurantId;
  const _OnlineToggle({required this.b, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(
          b.isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: b.isOnline ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Switch(
          value: b.isOnline,
          activeThumbColor: AppColors.success,
          onChanged: (v) {
            ref
                .read(branchControlsProvider.notifier)
                .toggleOnline(restaurantId, b.id, v);
          },
        ),
      ],
    );
  }
}
