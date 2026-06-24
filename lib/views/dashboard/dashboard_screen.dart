import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../services/order_service.dart';
import 'widgets/branch_stat_card.dart';
import 'widgets/live_orders_card.dart';
import 'widgets/onboarding_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<Map<String, dynamic>> _activeOrders = [];
  bool _ordersLoading = false;
  String _branchFilter = 'all';
  Timer? _ordersTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActiveOrders();
      _ordersTimer = Timer.periodic(
          const Duration(seconds: 30), (_) => _fetchActiveOrders());
    });
  }

  @override
  void dispose() {
    _ordersTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchActiveOrders() async {
    if (!mounted) return;
    setState(() => _ordersLoading = true);
    try {
      final orders = await ref.read(orderServiceProvider).getOrders(
            status: 'PLACED,CONFIRMED,PREPARING,READY_FOR_PICKUP',
            limit: 8,
          );
      if (mounted) {
        setState(() => _activeOrders = orders.map((o) => o.toJson()).toList());
      }
    } catch (_) {
      // dashboard works without live orders
    } finally {
      if (mounted) setState(() => _ordersLoading = false);
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(rawDashboardProvider);
    await _fetchActiveOrders();
  }

  static String _prettyNum(dynamic v) {
    try {
      final n = v is num ? v : (num.tryParse(v?.toString() ?? '') ?? 0);
      if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
      if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
      return n.toInt().toString();
    } catch (_) {
      return v?.toString() ?? '0';
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final dataAsync = ref.watch(rawDashboardProvider);

    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(err.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.adaptive.textSecondary)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(rawDashboardProvider),
              child: const Text('Retry'),
            ),
          ]),
        ),
        data: (data) => RefreshIndicator(
          color: context.adaptive.primaryColor,
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: _buildHero(context, data, user?.displayName ?? '')),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),

                    // ── Total branches gold card ─────────────────────────────
                    _buildTotalBranchesCard(context, data),
                    const SizedBox(height: 12),

                    // ── Online / Offline stat pills ──────────────────────────
                    Row(children: [
                      Expanded(
                          child: BranchStatCard(
                              label: 'Online',
                              value: data['activeBranches'] ?? 0,
                              icon: Icons.cloud_done_rounded)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: BranchStatCard(
                              label: 'Offline',
                              value: data['offlineBranches'] ?? 0,
                              icon: Icons.cloud_off_rounded)),
                    ]),
                    const SizedBox(height: 16),

                    // ── Revenue / Orders stat row ────────────────────────────
                    // _buildRevenueRow(data),
                    const SizedBox(height: 16),

                    // ── Live orders ──────────────────────────────────────────
                    LiveOrdersCard(
                      activeOrders: _activeOrders,
                      ordersLoading: _ordersLoading,
                      onRefresh: _fetchActiveOrders,
                    ),
                    const SizedBox(height: 16),

                    // ── Onboarding + Quick actions ───────────────────────────
                    OnboardingCard(data: data),
                    const SizedBox(height: 12),
                    // QuickActionsCard(data: data),
                    // const SizedBox(height: 16),

                    // ── Branch list with filter ──────────────────────────────
                    _buildBranchList(context, data),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ],
          ),
        ),
    );
  }

  // ── Hero section ────────────────────────────────────────────────────────────
  Widget _buildHero(
      BuildContext context, Map<String, dynamic> data, String displayName) {
    final restaurantName =
        data['restaurantName']?.toString() ?? data['name']?.toString() ?? '';
    final branchName =
        (data['branch'] is Map ? data['branch']['name'] : null)?.toString() ??
            data['branchName']?.toString() ??
            restaurantName;
    final status = (data['status'] ?? data['branchStatus'] ?? '').toString();
    final todayRevenue =
        data['todayRevenue'] ?? data['todaySales'] ?? data['today'] ?? 0;
    final todayOrders = data['todayOrders'] ?? data['orders'] ?? 0;
    final avgTime = data['avgOrderTime'] ?? data['avgTime'] ?? '--';

    final isDark = context.adaptive.isDark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkHeroGradient
            : const LinearGradient(
                colors: [Color(0xFF211039), Color(0xFF5A2DB4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Date + greeting row
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Good $_greeting',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 4),
              // Prefer restaurant name for the header title; fall back to user displayName
              Text(
                restaurantName.isNotEmpty
                    ? restaurantName
                    : (displayName.isNotEmpty ? displayName : 'Admin'),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.08,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w900),
              ),
            ]),
          ),
          Text(
            DateFormat('EEE, d MMM').format(DateTime.now()),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),

        const SizedBox(height: 6),

        // Active branch card inside hero
        if (branchName.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2D174E), Color(0xFF442069)]),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACTIVE BRANCH',
                            style: TextStyle(
                                color: Color(0xFFE7D8FF),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 6),
                        Text(branchName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                letterSpacing: -0.4,
                                fontWeight: FontWeight.w900)),
                      ]),
                ),
                if (status.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status.toLowerCase() == 'active' ||
                              status.toLowerCase() == 'online'
                          ? Colors.green[700]
                          : Colors.grey[700],
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(status.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11)),
                  ),
              ]),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              Row(children: [
                _heroMetric('TODAY', '₹${_prettyNum(todayRevenue)}'),
                _heroMetric('ORDERS', todayOrders.toString()),
                _heroMetric('AVG TIME', avgTime.toString()),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _heroMetric(String label, String value) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10.5,
                color: Colors.white60,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                letterSpacing: -0.4,
                fontWeight: FontWeight.w900)),
      ]),
    );
  }

  // ── Total branches gold card ─────────────────────────────────────────────
  Widget _buildTotalBranchesCard(BuildContext context, Map<String, dynamic> data) {
    final colors = context.adaptive;
    final total = data['totalBranches'] ?? data['branchesCount'] ?? 0;
    final online = data['activeBranches'] ?? data['onlineBranches'] ?? 0;
    final totalN =
        total is num ? total.toInt() : (int.tryParse(total.toString()) ?? 0);
    final onlineN =
        online is num ? online.toInt() : (int.tryParse(online.toString()) ?? 0);
    final offlineN = (totalN - onlineN).clamp(0, totalN);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: const Color(0xFFF0C35A).withValues(alpha: 0.9)),
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF0C35A).withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL BRANCHES',
              style: TextStyle(
                  color: Color(0xFF9B6A00),
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w900,
                  fontSize: 11)),
          const SizedBox(height: 8),
          Text(totalN.toString(),
              style: TextStyle(
                fontSize: 40,
                height: 0.96,
                letterSpacing: -1.4,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
              )),
          const SizedBox(height: 6),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('$onlineN online',
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 12),
              Text('$offlineN offline',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 8),
            // Toggle: switch between showing all branches and only online branches
          ]),
        ]),
        GestureDetector(
          onTap: () => context.go('/branches'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6DD),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF0C35A)),
            ),
            child: const Row(children: [
              Text('Manage',
                  style: TextStyle(
                      color: Color(0xFFB9A07A), fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: Color(0xFFB9A07A)),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── Branch list with filter ──────────────────────────────────────────────
  Widget _buildBranchList(BuildContext context, Map<String, dynamic> data) {
    final colors = context.adaptive;
    final raw = data['branchMetrics'];
    final branches = (raw is List)
        ? raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
        : <Map<String, dynamic>>[];

    final filtered = branches.where((b) {
      if (_branchFilter == 'online') return b['isOnline'] == true;
      if (_branchFilter == 'offline') return b['isOnline'] != true;
      return true;
    }).toList();

    if (branches.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Branch Status',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: colors.textPrimary)),
            Row(children: [
              for (final f in ['all', 'online', 'offline'])
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(f, style: const TextStyle(fontSize: 12)),
                    selected: _branchFilter == f,
                    selectedColor: colors.primaryColor.withValues(alpha: 0.22),
                    onSelected: (_) => setState(() => _branchFilter = f),
                  ),
                ),
            ]),
          ]),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                  'No ${_branchFilter != 'all' ? _branchFilter : ''} branches found.',
                  style: TextStyle(color: colors.textSecondary)),
            )
          else
            ...filtered.map((b) => _BranchTile(branch: b)),
        ]),
      ),
    );
  }
}

// ── Branch tile ──────────────────────────────────────────────────────────────
class _BranchTile extends StatelessWidget {
  const _BranchTile({required this.branch});
  final Map<String, dynamic> branch;

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final name = branch['name']?.toString() ?? '';
    final isOnline = branch['isOnline'] == true;
    final open = branch['openingTime']?.toString() ?? '';
    final close = branch['closingTime']?.toString() ?? '';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isOnline ? AppColors.success : AppColors.textSecondary,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(name,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: colors.textPrimary)),
      subtitle: Text(
          (open.isNotEmpty && close.isNotEmpty)
              ? '$open – $close'
              : 'Hours not set',
          style: TextStyle(fontSize: 12, color: colors.textSecondary)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isOnline ? colors.successSurface : colors.cardBorder,
        ),
        child: Text(
          isOnline ? 'Online' : 'Offline',
          style: TextStyle(
              color: isOnline ? AppColors.success : colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12),
        ),
      ),
    );
  }
}
