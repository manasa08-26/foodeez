import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/settlement_provider.dart';
import '../../widgets/stat_card.dart';

class SettlementScreen extends ConsumerWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(settlementSummaryProvider);
    final ordersAsync = ref.watch(settlementOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(settlementSummaryProvider);
          ref.invalidate(settlementOrdersProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: summaryAsync.when(
                  loading: () => const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(AppColors.primary)),
                    ),
                  ),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                  data: (summary) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Net payout banner ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's Settlement",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              AppFormatters.currency(summary.netPayout),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Net payout after ${AppFormatters.currency(summary.platformFee)} platform fee (5%)',
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Stats grid ─────────────────────────────────────
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            title: 'Gross Revenue',
                            value: AppFormatters.currency(summary.grossRevenue),
                            icon: Icons.currency_rupee_rounded,
                            color: AppColors.primary,
                          ),
                          StatCard(
                            title: 'Platform Fee (5%)',
                            value: AppFormatters.currency(summary.platformFee),
                            icon: Icons.percent_rounded,
                            color: AppColors.error,
                          ),
                          StatCard(
                            title: 'Delivered Orders',
                            value: summary.totalOrders.toString(),
                            icon: Icons.receipt_long_rounded,
                            color: AppColors.info,
                          ),
                          StatCard(
                            title: 'Net Payout',
                            value: AppFormatters.currency(summary.netPayout),
                            icon: Icons.account_balance_wallet_rounded,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text("Today's Delivered Orders",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),

            // ── Order rows ───────────────────────────────────────────────
            ordersAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(AppColors.primary)),
                  ),
                ),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: _ErrorCard(message: e.toString())),
              data: (orders) => orders.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 48, color: AppColors.textHint),
                              SizedBox(height: 12),
                              Text('No delivered orders today',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _OrderRow(order: orders[i]),
                          childCount: orders.length,
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final dynamic order; // SettlementOrder

  @override
  Widget build(BuildContext context) {
    String timeStr = '';
    try {
      if (order.createdAt != null) {
        final dt = DateTime.parse(order.createdAt).toLocal();
        timeStr = DateFormat('h:mm a').format(dt);
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.successSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check_circle_outline_rounded,
              color: AppColors.success, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('#${order.orderNumber}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            if (order.customerName != null && order.customerName!.isNotEmpty)
              Text(order.customerName!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            if (timeStr.isNotEmpty)
              Text(timeStr,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            AppFormatters.currency(order.netAmount),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.success),
          ),
          Text(
            'of ${AppFormatters.currency(order.total)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
        ]),
      ]),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(color: AppColors.error, fontSize: 13)),
        ),
      ]),
    );
  }
}
