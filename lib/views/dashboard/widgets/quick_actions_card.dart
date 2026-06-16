import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(Icons.store_mall_directory_rounded, 'Branches', '/branches',
          AppColors.primary),
      _QA(Icons.menu_book_rounded, 'Menu', '/branches', AppColors.accent),
      _QA(Icons.receipt_long_rounded, 'Orders', '/orders', AppColors.warning),
      _QA(Icons.kitchen_rounded, 'KDS', '/kds', AppColors.error),
      _QA(Icons.account_balance_wallet_rounded, 'Settlement', '/settlement',
          AppColors.success),
      _QA(Icons.description_outlined, 'Documents', '/documents', AppColors.info),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Quick Actions',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: actions
                .map((a) => _ActionTile(a: a))
                .toList(),
          ),
        ]),
      ),
    );
  }
}

class _QA {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  _QA(this.icon, this.label, this.route, this.color);
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.a});
  final _QA a;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(a.route),
      child: Container(
        decoration: BoxDecoration(
          color: a.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: a.color.withValues(alpha: 0.2)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(a.icon, color: a.color, size: 22),
          const SizedBox(height: 6),
          Text(
            a.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: a.color),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}
