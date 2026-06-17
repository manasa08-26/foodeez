import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

String _initial(String? s, [String fallback = 'A']) {
  final v = s ?? '';
  return v.isNotEmpty ? v[0].toUpperCase() : fallback;
}

class ShellScaffold extends ConsumerWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(currentUserProvider);
    debugPrint('User: $user');
    final canPop = context.canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref, location, user, canPop),
      drawer: _buildDrawer(context, ref, location, user),
      body: child,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref,
      String location, dynamic user, bool canPop) {
    final title = _titleFor(location);
    final isDashboard = location == '/dashboard';
    // Non-dashboard top-level routes: show back-to-dashboard arrow
    final isTopLevel = !canPop;
    final showDashboardBack = isTopLevel && !isDashboard;

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      leading: canPop
          // Deep sub-screen → pop back
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => context.pop(),
            )
          : showDashboardBack
              // Sibling route → go to dashboard
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary, size: 20),
                  onPressed: () => context.go('/dashboard'),
                )
              // Dashboard → hamburger menu
              : Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded,
                        color: AppColors.textPrimary),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
      title: isDashboard
          // Dashboard: logo + brand
          ? Row(children: [
              Image.asset('assets/images/logo.png',
                  width: 32, height: 32, fit: BoxFit.contain),
              const SizedBox(width: 8),
              const Text('Foodeez',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
            ])
          // Any other screen: page title
          : Text(title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 17)),
      actions: [
        if (isDashboard) ...[
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  _initial(user?.displayName),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDrawer(
      BuildContext context, WidgetRef ref, String location, dynamic user) {
    debugPrint('================ USER DATA ================');
    debugPrint(user.toString());
    debugPrint('Display Name: ${user?.displayName}');
    debugPrint('Email: ${user?.email}');
    debugPrint('==========================================');
    return Drawer(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient),
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Foodeez',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: Text(
                        _initial(user?.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Restaurant Admin',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Restaurant Admin',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // ── Nav items ────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _NavSection(title: 'Overview', items: [
                  _NavItem(Icons.dashboard_rounded, 'Dashboard', '/dashboard',
                      location),
                ]),
                _NavSection(title: 'Restaurant', items: [
                  _NavItem(Icons.store_rounded, 'My Restaurant', '/restaurant',
                      location),
                  _NavItem(Icons.description_outlined, 'Documents',
                      '/documents', location),
                  _NavItem(Icons.people_outline, 'Team', '/users', location),
                ]),
                _NavSection(title: 'Operations', items: [
                  _NavItem(Icons.store_mall_directory_rounded, 'Branches',
                      '/branches', location),
                  _NavItem(Icons.receipt_long_rounded, 'Orders', '/orders',
                      location),
                  _NavItem(Icons.kitchen_rounded, 'Live Kitchen (KDS)', '/kds',
                      location),
                  _NavItem(Icons.account_balance_wallet_rounded, 'Settlement',
                      '/settlement', location),
                ]),
              ],
            ),
          ),

          // ── Logout ──────────────────────────────────────────────────────
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Logout',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w500)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Map route prefixes to readable page titles.
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
      '/restaurant': 'My Restaurant',
      '/branches': 'Branches',
      '/orders': 'Orders',
      '/kds': 'Live Kitchen',
      '/settlement': 'Settlement',
      '/documents': 'Documents',
      '/users': 'Team',
    };
    for (final e in map.entries) {
      if (location.startsWith(e.key)) return e.value;
    }
    return 'Foodeez';
  }
}

class _NavSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _NavSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textHint,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentLocation;

  const _NavItem(this.icon, this.label, this.route, this.currentLocation);

  bool get _isActive =>
      currentLocation == route || currentLocation.startsWith('$route/');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: _isActive ? AppColors.primarySurface : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: _isActive ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: _isActive ? FontWeight.w600 : FontWeight.w400,
            color: _isActive ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
