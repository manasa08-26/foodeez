import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/restaurant_model.dart';
import '../../models/settlement_model.dart';
import '../../data/settlement_static_data.dart';
import '../../providers/settlement_provider.dart';
import '../../services/settlement_service.dart';

class SettlementScreen extends ConsumerStatefulWidget {
  const SettlementScreen({super.key});

  @override
  ConsumerState<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends ConsumerState<SettlementScreen> {
  SettlementPeriod _period = SettlementPeriod.today;
  bool _withdrawing = false;

  Future<void> _refresh() async {
    if (!SettlementStaticData.useLiveApis) {
      setState(() {});
      return;
    }
    ref.invalidate(settlementSummaryByPeriodProvider(_period));
    ref.invalidate(settlementOrdersByPeriodProvider(_period));
    ref.invalidate(recentPayoutsProvider);
    ref.invalidate(settlementRestaurantProvider);
  }

  Future<void> _withdraw() async {
    if (!SettlementStaticData.useLiveApis) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Withdraw will be available once the payouts API is live.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _withdrawing = true);
    try {
      await ref.read(settlementServiceProvider).requestWithdraw();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal request submitted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _withdrawing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SettlementStaticData.useLiveApis) {
      return _buildScaffold(
        summary: SettlementStaticData.summary(_period),
        payouts: SettlementStaticData.recentPayouts(),
        restaurant: SettlementStaticData.bankPreview(),
      );
    }

    final summaryAsync = ref.watch(settlementSummaryByPeriodProvider(_period));
    final payoutsAsync = ref.watch(recentPayoutsProvider);
    final restaurantAsync = ref.watch(settlementRestaurantProvider);

    return summaryAsync.when(
      loading: () => _buildScaffold(
        summary: null,
        payouts: null,
        restaurant: null,
        loading: true,
      ),
      error: (e, _) => _buildScaffold(
        summary: null,
        payouts: null,
        restaurant: null,
        error: e.toString(),
      ),
      data: (summary) => payoutsAsync.when(
        loading: () => _buildScaffold(
          summary: summary,
          payouts: null,
          restaurant: restaurantAsync.value,
          loadingPayouts: true,
        ),
        error: (e, _) => _buildScaffold(
          summary: summary,
          payouts: null,
          restaurant: restaurantAsync.value,
          payoutsError: e.toString(),
        ),
        data: (payouts) => _buildScaffold(
          summary: summary,
          payouts: payouts,
          restaurant: restaurantAsync.value,
        ),
      ),
    );
  }

  Widget _buildScaffold({
    required SettlementSummary? summary,
    required List<RecentPayout>? payouts,
    required RestaurantModel? restaurant,
    bool loading = false,
    bool loadingPayouts = false,
    String? error,
    String? payoutsError,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _PeriodTabs(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: error != null
                    ? _ErrorCard(message: error)
                    : loading || summary == null
                        ? const _LoadingBlock(height: 320)
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _NetPayoutHeroCard(
                                summary: summary,
                                period: _period,
                                withdrawing: _withdrawing,
                                onWithdraw: _withdraw,
                              ),
                              const SizedBox(height: 14),
                              _MetricsGrid(summary: summary),
                              const SizedBox(height: 14),
                              _BreakdownCard(
                                summary: summary,
                                period: _period,
                                restaurant: restaurant,
                              ),
                            ],
                          ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Recent Payouts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View all',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (loadingPayouts)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _LoadingBlock(height: 120),
                ),
              )
            else if (payoutsError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ErrorCard(message: payoutsError),
                ),
              )
            else if (payouts == null || payouts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: _EmptyPayoutsCard(restaurant: restaurant),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecentPayoutTile(
                        payout: payouts[i],
                        fallbackBank: restaurant?.bankName,
                        fallbackAccount: restaurant?.bankAccountNumber,
                      ),
                    ),
                    childCount: payouts.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.selected, required this.onChanged});

  final SettlementPeriod selected;
  final ValueChanged<SettlementPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: SettlementPeriod.values.map((period) {
          final active = period == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  period.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: active ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NetPayoutHeroCard extends StatelessWidget {
  const _NetPayoutHeroCard({
    required this.summary,
    required this.period,
    required this.withdrawing,
    required this.onWithdraw,
  });

  final SettlementSummary summary;
  final SettlementPeriod period;
  final bool withdrawing;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final feeLabel = summary.platformFeeRate > 0
        ? 'After ${summary.platformFeeRate.toStringAsFixed(0)}% platform fee'
        : 'After platform fee';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B3FE4), Color(0xFF4C1D95)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period.netPayoutTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.78),
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feeLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ),
                ),
                if (summary.isSettled)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      (summary.status ?? 'SETTLED').toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                AppFormatters.currency(summary.netPayout),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEXT TRANSFER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.62),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatNextTransfer(summary.nextTransferAt),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: withdrawing ? null : onWithdraw,
                  icon: withdrawing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text(
                    'Withdraw',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNextTransfer(String? iso) {
    if (iso == null || iso.isEmpty) return 'Scheduled by platform';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final day = DateTime(dt.year, dt.month, dt.day);
      final label =
          day == tomorrow ? 'Tomorrow' : DateFormat('EEE, d MMM').format(dt);
      return '$label, ${DateFormat('h:mm a').format(dt)}';
    } catch (_) {
      return iso;
    }
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.summary});

  final SettlementSummary summary;

  @override
  Widget build(BuildContext context) {
    final feeRate = summary.platformFeeRate > 0
        ? '${summary.platformFeeRate.toStringAsFixed(0)}% of gross'
        : 'Platform fee';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                title: 'Gross Revenue',
                value: AppFormatters.currency(summary.grossRevenue),
                subtitle: null,
                color: AppColors.primary,
                icon: Icons.currency_rupee_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                title: 'Platform Fee',
                value: '- ${AppFormatters.currency(summary.platformFee)}',
                subtitle: feeRate,
                color: AppColors.error,
                icon: Icons.percent_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                title: 'Delivered Orders',
                value: summary.orderCount.toString(),
                subtitle: null,
                color: AppColors.info,
                icon: Icons.local_shipping_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricTile(
                title: 'Avg. Order',
                value: AppFormatters.currency(summary.avgOrderValue),
                subtitle: null,
                color: AppColors.success,
                icon: Icons.trending_up_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final String value;
  final String? subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.4,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.summary,
    required this.period,
    this.restaurant,
  });

  final SettlementSummary summary;
  final SettlementPeriod period;
  final RestaurantModel? restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Settlement Breakdown',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                period.breakdownLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BreakdownRow(
            label: 'Gross revenue',
            value: AppFormatters.currency(summary.grossRevenue),
          ),
          _BreakdownRow(
            label: summary.platformFeeRate > 0
                ? 'Platform fee (${summary.platformFeeRate.toStringAsFixed(0)}%)'
                : 'Platform fee',
            value: '- ${AppFormatters.currency(summary.platformFee)}',
            valueColor: AppColors.error,
          ),
          _BreakdownRow(
            label: 'Taxes & adjustments',
            value: AppFormatters.currency(summary.taxesAndAdjustments),
          ),
          const Divider(height: 24),
          _BreakdownRow(
            label: 'Net payout',
            value: AppFormatters.currency(summary.netPayout),
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            valueStyle: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          if (restaurant != null &&
              (restaurant!.bankName?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 14),
            _BankInfoBanner(restaurant: restaurant!),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: labelStyle ??
                  GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Text(
            value,
            style: valueStyle ??
                GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _BankInfoBanner extends StatelessWidget {
  const _BankInfoBanner({required this.restaurant});

  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    final bank = restaurant.bankName ?? 'Bank';
    final masked = _maskAccount(restaurant.bankAccountNumber);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Payouts are transferred to your linked $bank $masked account.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPayoutTile extends StatelessWidget {
  const _RecentPayoutTile({
    required this.payout,
    this.fallbackBank,
    this.fallbackAccount,
  });

  final RecentPayout payout;
  final String? fallbackBank;
  final String? fallbackAccount;

  @override
  Widget build(BuildContext context) {
    final bank = payout.bankName ?? fallbackBank ?? 'Bank';
    final account = payout.accountLast4 != null
        ? '•••• ${payout.accountLast4}'
        : _maskAccount(fallbackAccount);
    final date = _formatPayoutDate(payout.paidAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.credit_card_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payout.reference.isNotEmpty
                      ? payout.reference
                      : 'Payout ${payout.id}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  [if (date.isNotEmpty) date, '$bank $account']
                      .where((s) => s.isNotEmpty)
                      .join(' • '),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.currency(payout.amount),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  payout.isPaid ? 'Paid' : payout.status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPayoutsCard extends StatelessWidget {
  const _EmptyPayoutsCard({this.restaurant});

  final RestaurantModel? restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 40, color: AppColors.textHint),
          const SizedBox(height: 10),
          Text(
            'No recent payouts yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          if (restaurant != null &&
              (restaurant!.bankName?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 14),
            _BankInfoBanner(restaurant: restaurant!),
          ],
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _maskAccount(String? account) {
  if (account == null || account.isEmpty) return '••••';
  if (account.length <= 4) return '•••• $account';
  return '•••• ${account.substring(account.length - 4)}';
}

String _formatPayoutDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    return DateFormat('d MMM').format(DateTime.parse(iso).toLocal());
  } catch (_) {
    return '';
  }
}
