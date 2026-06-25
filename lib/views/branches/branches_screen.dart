import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/branch_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId == null) {
      return const Center(child: Text('No restaurant linked'));
    }

    final branchesAsync = ref.watch(branchesProvider(restaurantId));
    final colors = context.adaptive;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colors.isDark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.cardBorder;
    final titleColor = colorScheme.onSurface;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Stack(
      children: [
        Positioned.fill(
          child: branchesAsync.when(
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
                color: colors.primaryColor,
                onRefresh: () =>
                    ref.refresh(branchesProvider(restaurantId).future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
                  itemCount: branches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final b = branches[i];
                    return Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.035),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => context.go('/branches/${b.id}'),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkPrimarySurface
                                        : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.store_mall_directory_rounded,
                                    color: colors.primaryColor,
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.15,
                                          letterSpacing: -0.35,
                                          fontWeight: FontWeight.w900,
                                          color: titleColor,
                                        ),
                                      ),
                                      if (b.city != null)
                                        Text(
                                          [b.city, b.state]
                                              .where((e) => e != null)
                                              .join(', '),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: subtitleColor,
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
                          ),
                          if (b.openingTime != null || b.closingTime != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 14, color: subtitleColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${b.openingTime ?? ''} – ${b.closingTime ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _Action(Icons.menu_book_rounded, 'Menu',
                                  () => context.push('/branches/${b.id}/menu')),
                              const SizedBox(width: 8),
                              _Action(
                                  Icons.tune_rounded,
                                  'Controls',
                                  () => context
                                      .push('/branches/${b.id}/controls')),
                              const Spacer(),
                              _OnlineToggle(
                                branch: b,
                                restaurantId: restaurantId,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 88,
          child: FloatingActionButton.extended(
            onPressed: () => context.go('/branches/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add Branch'),
            backgroundColor: colors.primaryColor,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
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
    final colors = context.adaptive;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: colors.primarySurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: colors.primaryColor),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.primaryColor)),
          ],
        ),
      ),
    );
  }
}

class _OnlineToggle extends ConsumerStatefulWidget {
  const _OnlineToggle({required this.branch, required this.restaurantId});

  final BranchModel branch;
  final String restaurantId;

  @override
  ConsumerState<_OnlineToggle> createState() => _OnlineToggleState();
}

class _OnlineToggleState extends ConsumerState<_OnlineToggle> {
  late bool _isOnline;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.branch.isOnline;
  }

  @override
  void didUpdateWidget(covariant _OnlineToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branch.id != widget.branch.id ||
        oldWidget.branch.isOnline != widget.branch.isOnline) {
      _isOnline = widget.branch.isOnline;
    }
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;
    final previous = _isOnline;
    setState(() {
      _isOnline = value;
      _busy = true;
    });

    final ok = await ref.read(branchControlsProvider.notifier).toggleOnline(
          widget.restaurantId,
          widget.branch.id,
          value,
        );

    if (!mounted) return;
    if (!ok) {
      setState(() => _isOnline = previous);
      final error = ref.read(branchControlsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Could not update branch status'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final subtitleColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isOnline ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _isOnline ? AppColors.success : subtitleColor,
          ),
        ),
        const SizedBox(width: 6),
        AppSwitch(
          value: _isOnline,
          onChanged: _busy ? null : _onChanged,
          onColor: AppColors.success,
        ),
      ],
    );
  }
}
