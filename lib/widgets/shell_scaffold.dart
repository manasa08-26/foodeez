import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/branch_provider.dart';

String _initial(String? s, [String fallback = 'A']) {
  final v = s ?? '';
  return v.isNotEmpty ? v[0].toUpperCase() : fallback;
}

class ShellScaffold extends ConsumerWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final location = state.matchedLocation;
    final currentPath = state.uri.path;
    final user = ref.watch(currentUserProvider);
    final canPop = context.canPop();

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (currentPath != '/dashboard') {
          context.go('/dashboard');
        }
        return true; // Consume Android back so the app never closes here.
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (currentPath != '/dashboard') {
            context.go('/dashboard');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar:
              _buildAppBar(context, ref, location, currentPath, user, canPop),
          body: child,
          bottomNavigationBar: _showFooterFor(location)
              ? _FooterNavigation(location: location)
              : null,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    String location,
    String currentPath,
    dynamic user,
    bool canPop,
  ) {
    final title = _titleFor(location);
    final isDashboard = location == '/dashboard';
    final showDashboardBack = !canPop && !isDashboard;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      toolbarHeight: 64,
      leadingWidth: isDashboard ? 54 : 48,
      leading: isDashboard
          ? Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Image.asset(
                'assets/images/logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.contain,
              ),
            )
          : canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary, size: 19),
                  onPressed: () => context.go('/dashboard'),
                )
              : showDashboardBack
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary, size: 19),
                      onPressed: () => context.go('/dashboard'),
                    )
                  : null,
      titleSpacing: isDashboard ? 4 : 0,
      title: isDashboard
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Foodeez',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.05,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Restaurant admin',
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    height: 1.15,
                  ),
                ),
              ],
            )
          : Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
      actions: [
        if (isDashboard)
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textPrimary, size: 23),
            onPressed: () {},
          ),
        _HeaderOnlineSwitch(location: currentPath),
        _ProfileMenu(ref: ref, user: user),
        const SizedBox(width: 8),
      ],
    );
  }

  static bool _showFooterFor(String location) {
    const hiddenPrefixes = {
      '/branches/new',
      '/branches/:branchId/menu/category',
      '/branches/:branchId/menu/item',
      '/restaurant/onboarding',
      '/orders/:orderId',
    };
    return !hiddenPrefixes.any(location.startsWith);
  }

  static String _titleFor(String location) {
    if (location.startsWith('/branches') && location.contains('/menu')) {
      return 'Menu';
    }
    if (location.startsWith('/branches') && location.contains('/controls')) {
      return 'Branch Controls';
    }
    if (location.startsWith('/branches/new')) return 'New Branch';
    if (location.startsWith('/branches/') && location.split('/').length > 2) {
      return 'Branch Detail';
    }
    if (location.startsWith('/orders/')) return 'Order Detail';
    if (location == '/restaurant/onboarding') return 'Onboarding';

    const map = {
      '/dashboard': 'Dashboard',
      '/restaurant': 'Restaurant',
      '/branches': 'Branches',
      '/orders': 'Orders',
      '/kds': 'Kitchen',
      '/settlement': 'Payouts',
      '/documents': 'Documents',
      '/users': 'Team',
    };
    for (final e in map.entries) {
      if (location.startsWith(e.key)) return e.value;
    }
    return 'Foodeez';
  }
}

class _FooterNavigation extends StatelessWidget {
  const _FooterNavigation({required this.location});

  final String location;

  static const _items = [
    _FooterItem(
      route: '/dashboard',
      label: 'Home',
      icon: Icons.grid_view_rounded,
      selectedIcon: Icons.grid_view_rounded,
    ),
    _FooterItem(
      route: '/branches',
      label: 'Branches',
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
    ),
    _FooterItem(
      route: '/orders',
      label: 'Orders',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _FooterItem(
      route: '/kds',
      label: 'Kitchen',
      icon: Icons.soup_kitchen_outlined,
      selectedIcon: Icons.soup_kitchen_rounded,
    ),
    _FooterItem(
      route: '/settlement',
      label: 'Payouts',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet_rounded,
    ),
  ];

  int get _selectedIndex {
    final index = _items.indexWhere((item) => location == item.route);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 26,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _FooterTile(
                  item: _items[index],
                  selected: index == _selectedIndex,
                  onTap: () {
                    final route = _items[index].route;
                    if (route != location) context.go(route);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FooterTile extends StatelessWidget {
  const _FooterTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _FooterItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              size: selected ? 23 : 22,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: selected ? 11.5 : 10.8,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                height: 1,
                letterSpacing: -0.25,
                color: selected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _FooterItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.ref, required this.user});

  final WidgetRef ref;
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProfileAction>(
      tooltip: 'Account',
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ProfileAction.restaurant,
          child: _ProfileMenuRow(Icons.storefront_rounded, 'Restaurant'),
        ),
        PopupMenuItem(
          value: _ProfileAction.team,
          child: _ProfileMenuRow(Icons.group_outlined, 'Team'),
        ),
        PopupMenuItem(
          value: _ProfileAction.documents,
          child: _ProfileMenuRow(Icons.description_outlined, 'Documents'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _ProfileAction.logout,
          child: _ProfileMenuRow(
            Icons.logout_rounded,
            'Logout',
            color: AppColors.error,
          ),
        ),
      ],
      onSelected: (action) async {
        switch (action) {
          case _ProfileAction.restaurant:
            context.go('/restaurant');
          case _ProfileAction.team:
            context.go('/users');
          case _ProfileAction.documents:
            context.go('/documents');
          case _ProfileAction.logout:
            await ref.read(authProvider.notifier).logout();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primarySurface,
          child: Text(
            _initial(user?.displayName),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

enum _ProfileAction { restaurant, team, documents, logout }

class _HeaderOnlineSwitch extends ConsumerStatefulWidget {
  const _HeaderOnlineSwitch({required this.location});

  final String location;

  @override
  ConsumerState<_HeaderOnlineSwitch> createState() =>
      _HeaderOnlineSwitchState();
}

class _HeaderOnlineSwitchState extends ConsumerState<_HeaderOnlineSwitch> {
  final Map<String, bool> _localStatus = {};
  final Set<String> _updatingBranches = {};

  String? get _routeBranchId {
    final segments =
        widget.location.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.length >= 2 && segments.first == 'branches') {
      final id = segments[1];
      if (id != 'new') return id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId == null || restaurantId.isEmpty) {
      return const SizedBox.shrink();
    }

    final branchesAsync = ref.watch(branchesProvider(restaurantId));

    return branchesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(right: 6),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (branches) {
        if (branches.isEmpty) return const SizedBox.shrink();

        final currentBranchId = _routeBranchId;
        final branch = currentBranchId == null
            ? branches.first
            : branches.firstWhere(
                (b) => b.id == currentBranchId,
                orElse: () => branches.first,
              );
        final isOnline = _localStatus[branch.id] ?? branch.isOnline;
        final isBusy = _updatingBranches.contains(branch.id);

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: isBusy
                ? null
                : () => _toggle(context, restaurantId, branch.id, !isOnline),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
              decoration: BoxDecoration(
                color: isOnline
                    ? AppColors.successSurface
                    : AppColors.errorSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: (isOnline ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Container(
                  //   width: 7,
                  //   height: 7,
                  //   decoration: BoxDecoration(
                  //     color: isOnline ? AppColors.success : AppColors.error,
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                  // const SizedBox(width: 6),
                  // Text(
                  //   isOnline ? 'Online' : 'Offline',
                  //   style: TextStyle(
                  //     color: isOnline ? AppColors.success : AppColors.error,
                  //     fontSize: 11.5,
                  //     height: 1,
                  //     fontWeight: FontWeight.w900,
                  //     letterSpacing: -0.2,
                  //   ),
                  // ),
                  //  const SizedBox(width: 4),
                  SizedBox(
                    width: 34,
                    height: 24,
                    child: Switch(
                      value: isOnline,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: AppColors.white,
                      activeTrackColor: AppColors.success,
                      inactiveThumbColor: AppColors.white,
                      inactiveTrackColor:
                          AppColors.error.withValues(alpha: 0.78),
                      onChanged: isBusy
                          ? null
                          : (v) => _toggle(context, restaurantId, branch.id, v),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggle(
    BuildContext context,
    String restaurantId,
    String branchId,
    bool value,
  ) async {
    setState(() {
      _localStatus[branchId] = value;
      _updatingBranches.add(branchId);
    });

    final ok = await ref
        .read(branchControlsProvider.notifier)
        .toggleOnline(restaurantId, branchId, value);

    if (!mounted) return;
    if (!ok) {
      setState(() {
        _localStatus[branchId] = !value;
        _updatingBranches.remove(branchId);
      });
    } else {
      setState(() {
        _localStatus[branchId] = value;
        _updatingBranches.remove(branchId);
      });
    }

    ref.invalidate(branchesProvider(restaurantId));
    ref.invalidate(branchProvider((restaurantId, branchId)));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Branch marked ${value ? 'online' : 'offline'}'
            : 'Could not update branch status'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow(this.icon, this.label, {this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 19, color: itemColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: itemColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
