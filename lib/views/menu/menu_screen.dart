import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/menu_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/menu_restricted_toggle_dialog.dart';

class MenuScreen extends ConsumerWidget {
  final String branchId;
  const MenuScreen({super.key, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.adaptive;
    final categoriesAsync = ref.watch(menuCategoriesProvider(branchId));

    return Stack(
      children: [
        Positioned.fill(
          child: categoriesAsync.when(
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
                    color: colors.primaryColor,
                    onRefresh: () =>
                        ref.refresh(menuCategoriesProvider(branchId).future),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (_, i) => _CategoryCard(
                        branchId: branchId,
                        category: categories[i],
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 88,
          child: FloatingActionButton.extended(
            onPressed: () => context.go('/branches/$branchId/menu/item/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            backgroundColor: colors.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final String branchId;
  final MenuCategory category;
  const _CategoryCard({required this.branchId, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.adaptive;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.go(
                        '/branches/$branchId/menu/category/${category.id}/edit'),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.category_rounded,
                              color: colors.primaryColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.displayName ?? category.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                '${category.visibleItemCount} items',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.edit_outlined,
                            size: 16, color: colors.textHint),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _CategoryVisibilityToggle(
                  branchId: branchId,
                  category: category,
                ),
              ],
            ),
          ),
          if (category.items.isNotEmpty) ...[
            Divider(height: 1, color: colors.cardBorder),
            ...category.items.map((item) => _MenuItemRow(
                  branchId: branchId,
                  item: item,
                )),
          ],
          InkWell(
            onTap: () => context.go(
                '/branches/$branchId/menu/item/new?categoryId=${category.id}'),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.add, size: 18, color: colors.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Add item to this category',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
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

class _CategoryVisibilityToggle extends ConsumerStatefulWidget {
  const _CategoryVisibilityToggle({
    required this.branchId,
    required this.category,
  });

  final String branchId;
  final MenuCategory category;

  @override
  ConsumerState<_CategoryVisibilityToggle> createState() =>
      _CategoryVisibilityToggleState();
}

class _CategoryVisibilityToggleState
    extends ConsumerState<_CategoryVisibilityToggle> {
  late bool _isVisible;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.category.isVisible;
  }

  @override
  void didUpdateWidget(covariant _CategoryVisibilityToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id ||
        oldWidget.category.isVisible != widget.category.isVisible) {
      _isVisible = widget.category.isVisible;
    }
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;
    final previous = _isVisible;
    setState(() {
      _isVisible = value;
      _busy = true;
    });

    final ok = await ref.read(menuNotifierProvider.notifier).updateCategory(
          widget.category.id,
          {'isVisible': value},
        );

    if (!mounted) return;

    if (ok) {
      ref.invalidate(menuCategoriesProvider(widget.branchId));
    } else {
      setState(() => _isVisible = previous);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update category visibility'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppSwitch(
      value: _isVisible,
      onChanged: _busy ? null : _onChanged,
    );
  }
}

class _MenuItemRow extends ConsumerWidget {
  final String branchId;
  final MenuItem item;
  const _MenuItemRow({required this.branchId, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.adaptive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () =>
                  context.go('/branches/$branchId/menu/item/${item.id}/edit'),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholder(colors),
                          )
                        : _placeholder(colors),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: item.isVisible
                                      ? colors.textPrimary
                                      : colors.textHint,
                                ),
                              ),
                            ),
                            if (item.discountLabel != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.successSurface,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.discountLabel!,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (item.description != null &&
                            item.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (item.activeDiscount != null) ...[
                              Text(
                                AppFormatters.currency(item.price),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textHint,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppFormatters.currency(item.discountedPrice),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primaryColor,
                                ),
                              ),
                            ] else
                              Text(
                                AppFormatters.currency(item.price),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.primaryColor,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: colors.textHint, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MenuItemStockToggle(branchId: branchId, item: item),
          const SizedBox(width: 4),
          _MenuItemVisibilityToggle(branchId: branchId, item: item),
        ],
      ),
    );
  }

  Widget _placeholder(AdaptiveAppColors colors) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.fastfood_rounded,
          color: colors.primaryColor, size: 22),
    );
  }
}

class _MenuItemStockToggle extends ConsumerStatefulWidget {
  const _MenuItemStockToggle({required this.branchId, required this.item});

  final String branchId;
  final MenuItem item;

  @override
  ConsumerState<_MenuItemStockToggle> createState() =>
      _MenuItemStockToggleState();
}

class _MenuItemStockToggleState extends ConsumerState<_MenuItemStockToggle> {
  late bool _inStock;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _inStock = widget.item.isInStock;
  }

  @override
  void didUpdateWidget(covariant _MenuItemStockToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.isInStock != widget.item.isInStock) {
      _inStock = widget.item.isInStock;
    }
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;

    final role = ref.read(currentUserProvider)?.role;
    if (itemToggleRequiresApproval(role)) {
      await showMenuRestrictedToggleDialog(
        context,
        field: 'isInStock',
        itemName: widget.item.name,
      );
      return;
    }

    final previous = _inStock;
    setState(() {
      _inStock = value;
      _busy = true;
    });

    final ok = await ref
        .read(menuNotifierProvider.notifier)
        .toggleStock(widget.item.id, value);

    if (!mounted) return;

    if (ok) {
      ref.invalidate(menuCategoriesProvider(widget.branchId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? '${widget.item.name} marked in stock'
                  : '${widget.item.name} marked out of stock',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() => _inStock = previous);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update stock status'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;

    return Column(
      children: [
        Text('Stock',
            style: TextStyle(fontSize: 10, color: colors.textSecondary)),
        AppSwitch(
          value: _inStock,
          onChanged: _busy ? null : _onChanged,
        ),
      ],
    );
  }
}

class _MenuItemVisibilityToggle extends ConsumerStatefulWidget {
  const _MenuItemVisibilityToggle({
    required this.branchId,
    required this.item,
  });

  final String branchId;
  final MenuItem item;

  @override
  ConsumerState<_MenuItemVisibilityToggle> createState() =>
      _MenuItemVisibilityToggleState();
}

class _MenuItemVisibilityToggleState
    extends ConsumerState<_MenuItemVisibilityToggle> {
  late bool _isVisible;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.item.isVisible;
  }

  @override
  void didUpdateWidget(covariant _MenuItemVisibilityToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.isVisible != widget.item.isVisible) {
      _isVisible = widget.item.isVisible;
    }
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;

    final role = ref.read(currentUserProvider)?.role;
    if (itemToggleRequiresApproval(role)) {
      await showMenuRestrictedToggleDialog(
        context,
        field: 'isVisible',
        itemName: widget.item.name,
      );
      return;
    }

    final previous = _isVisible;
    setState(() {
      _isVisible = value;
      _busy = true;
    });

    final ok = await ref
        .read(menuNotifierProvider.notifier)
        .toggleVisibility(widget.item.id, value);

    if (!mounted) return;

    if (ok) {
      ref.invalidate(menuCategoriesProvider(widget.branchId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? '${widget.item.name} is now visible'
                  : '${widget.item.name} is now hidden',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      setState(() => _isVisible = previous);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update visibility'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;

    return Column(
      children: [
        Text('Visible',
            style: TextStyle(fontSize: 10, color: colors.textSecondary)),
        AppSwitch(
          value: _isVisible,
          onChanged: _busy ? null : _onChanged,
        ),
      ],
    );
  }
}
