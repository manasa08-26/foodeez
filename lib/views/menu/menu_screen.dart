import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/menu_model.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';

class MenuScreen extends ConsumerWidget {
  final String branchId;
  const MenuScreen({super.key, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(menuCategoriesProvider(branchId));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/branches/$branchId/menu/item/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: categoriesAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(menuCategoriesProvider(branchId)),
        ),
        data: (categories) => categories.isEmpty
            ? EmptyState(
                icon: Icons.menu_book_rounded,
                title: 'No menu yet',
                subtitle: 'Start by adding a category',
                actionLabel: 'Add Category',
                onAction: () =>
                    context.go('/branches/$branchId/menu/category/new'),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () =>
                    ref.refresh(menuCategoriesProvider(branchId).future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _CategoryCard(
                      branchId: branchId, category: categories[i]),
                ),
              ),
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final String branchId;
  final MenuCategory category;
  const _CategoryCard({required this.branchId, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // Category header
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => context
                .go('/branches/$branchId/menu/category/${category.id}/edit'),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.category_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.displayName ?? category.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${category.visibleItemCount} items',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _VisibilityToggle(category: category, ref: ref),
                  const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.textHint),
                ],
              ),
            ),
          ),
          if (category.items.isNotEmpty) ...[
            const Divider(height: 1),
            ...category.items.map((item) => _MenuItemRow(
                  branchId: branchId,
                  item: item,
                  ref: ref,
                )),
          ],
          // Add item to this category
          InkWell(
            onTap: () => context.go(
                '/branches/$branchId/menu/item/new?categoryId=${category.id}'),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.add, size: 18, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Add item to this category',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final MenuCategory category;
  final WidgetRef ref;
  const _VisibilityToggle({required this.category, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: category.isVisible,
      activeThumbColor: AppColors.primary,
      onChanged: (v) {
        ref
            .read(menuNotifierProvider.notifier)
            .updateCategory(category.id, {'isVisible': v});
      },
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final String branchId;
  final MenuItem item;
  final WidgetRef ref;
  const _MenuItemRow(
      {required this.branchId, required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/branches/$branchId/menu/item/${item.id}/edit'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: item.isVisible
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  Text(
                    AppFormatters.currency(item.price),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary),
                  ),
                ],
              ),
            ),
            // In stock toggle
            Column(
              children: [
                const Text('Stock',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textSecondary)),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: item.isInStock,
                    activeThumbColor: AppColors.success,
                    onChanged: (v) {
                      ref
                          .read(menuNotifierProvider.notifier)
                          .toggleStock(item.id, v);
                    },
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fastfood_rounded,
          color: AppColors.primary, size: 22),
    );
  }
}
