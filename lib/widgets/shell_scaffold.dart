import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_switch.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/branch_provider.dart';
import '../providers/theme_provider.dart';
import 'partner_logo.dart';

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
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return BackButtonListener(
      onBackButtonPressed: () async {
        _handleBack(context, currentPath);
        return true; // Consume Android back so the app never closes here.
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _handleBack(context, currentPath);
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _buildAppBar(
            context,
            ref,
            location,
            currentPath,
            user,
            canPop,
            isDark,
          ),
          body: KeyedSubtree(
            key: state.pageKey,
            child: child,
          ),
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
    bool isDark,
  ) {
    final title = _titleFor(currentPath);
    final isDashboard = location == '/dashboard';
    final showDashboardBack = !canPop && !isDashboard;
    final titleColor = Theme.of(context).colorScheme.onSurface;

    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: isDark ? Colors.black26 : AppColors.border,
      toolbarHeight: 64,
      leadingWidth: isDashboard ? 60 : 48,
      leading: isDashboard
          ? null
          : canPop
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: titleColor, size: 19),
                  onPressed: () => _handleBack(context, currentPath),
                )
              : showDashboardBack
                  ? IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: titleColor, size: 19),
                      onPressed: () => _handleBack(context, currentPath),
                    )
                  : null,
      titleSpacing: isDashboard ? 0 : 0,
      title: isDashboard
          ? const Align(
              alignment: Alignment.centerLeft,
              child: PartnerLogo.custom(width: 108, height: 40),
            )
          : Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
      actions: [
        if (isDashboard)
          IconButton(
            icon: Icon(Icons.notifications_none_rounded,
                color: titleColor, size: 23),
            onPressed: () {},
          ),
        IconButton(
          tooltip: isDark ? 'Light mode' : 'Dark mode',
          icon: Icon(
            isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
            color: titleColor,
            size: 23,
          ),
          onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
        ),
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

  static String _titleFor(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isNotEmpty && segments[0] == 'branches') {
      if (segments.length == 1) return 'Branches';
      if (segments[1] == 'new') return 'New Branch';

      if (segments.length >= 3 && segments[2] == 'controls') {
        return 'Branch Controls';
      }
      if (segments.length >= 3 && segments[2] == 'menu') {
        if (path.contains('/menu/item')) {
          return path.contains('/edit') ? 'Edit Menu Item' : 'New Menu Item';
        }
        if (path.contains('/menu/category')) {
          return path.contains('/edit') ? 'Edit Category' : 'New Category';
        }
        return 'Menu';
      }
      if (segments.length == 2) return 'Branch';
    }

    if (path.startsWith('/orders/') && segments.length >= 2)
      return 'Order Detail';
    if (path == '/restaurant/onboarding') return 'Onboarding';

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
      if (path.startsWith(e.key)) return e.value;
    }
    return 'Foodeez';
  }

  static void _handleBack(BuildContext context, String currentPath) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final target = _backTargetFor(currentPath);
    if (currentPath != target) {
      context.go(target);
    }
  }

  /// Parent route when [context.pop] is unavailable (go_router stack).
  static String _backTargetFor(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return '/dashboard';

    if (segments[0] == 'branches') {
      if (segments.length == 1) return '/dashboard';
      if (segments[1] == 'new') return '/branches';

      final branchId = segments[1];
      if (segments.length >= 4 && segments[2] == 'menu') {
        return '/branches/$branchId/menu';
      }
      if (segments.length >= 3 && segments[2] == 'menu') {
        return '/branches';
      }
      if (segments.length >= 3 && segments[2] == 'controls') {
        return '/branches/$branchId';
      }
      if (segments.length >= 2) return '/branches';
      return '/branches';
    }

    if (segments[0] == 'orders' && segments.length >= 2) return '/orders';

    return '/dashboard';
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
    // _FooterItem(
    //   route: '/kds',
    //   label: 'Kitchen',
    //   icon: Icons.soup_kitchen_outlined,
    //   selectedIcon: Icons.soup_kitchen_rounded,
    // ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.adaptive;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colors.cardBorder.withValues(alpha: isDark ? 0.9 : 0.65),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
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
    final colors = context.adaptive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? colors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.selectedIcon : item.icon,
              size: selected ? 23 : 22,
              color: selected ? colors.primaryColor : colors.textSecondary,
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
                color: selected ? colors.primaryColor : colors.textHint,
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
          child: _ProfileMenuRow(Icons.storefront_outlined, 'My Restaurant'),
        ),
        PopupMenuItem(
          value: _ProfileAction.team,
          child: _ProfileMenuRow(Icons.people_outline, 'Team & Members'),
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
          backgroundColor: context.adaptive.primarySurface,
          child: Text(
            _initial(user?.displayName),
            style: TextStyle(
              color: context.adaptive.primaryColor,
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
                    child: AppSwitch(
                      value: isOnline,
                      onChanged: isBusy
                          ? null
                          : (v) => _toggle(context, restaurantId, branch.id, v),
                      onColor: AppColors.success,
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
    final itemColor = color ?? context.adaptive.textPrimary;
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
