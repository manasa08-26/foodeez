import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/menu_model.dart';
import '../services/menu_service.dart';

final menuCategoriesProvider =
    FutureProvider.autoDispose.family<List<MenuCategory>, String>(
        (ref, branchId) async {
  return ref.read(menuServiceProvider).getBranchMenu(branchId);
});

final selectedCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

MenuItem? findMenuItem(List<MenuCategory> categories, String itemId) {
  for (final category in categories) {
    for (final item in category.items) {
      if (item.id == itemId) return item;
    }
  }
  return null;
}

MenuCategory? findMenuCategory(List<MenuCategory> categories, String id) {
  for (final category in categories) {
    if (category.id == id) return category;
  }
  return null;
}

class MenuActionState {
  final bool isLoading;
  final String? error;
  const MenuActionState({this.isLoading = false, this.error});
}

class MenuNotifier extends Notifier<MenuActionState> {
  @override
  MenuActionState build() => const MenuActionState();

  Future<bool> createCategory(
      String branchId, Map<String, dynamic> data) async {
    state = const MenuActionState(isLoading: true);
    try {
      await ref.read(menuServiceProvider).createCategory(branchId, data);
      state = const MenuActionState();
      return true;
    } catch (e) {
      state = MenuActionState(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCategory(
      String categoryId, Map<String, dynamic> data) async {
    state = const MenuActionState(isLoading: true);
    try {
      await ref.read(menuServiceProvider).updateCategory(categoryId, data);
      state = const MenuActionState();
      return true;
    } catch (e) {
      state = MenuActionState(error: e.toString());
      return false;
    }
  }

  Future<bool> createItem(String branchId, Map<String, dynamic> data) async {
    state = const MenuActionState(isLoading: true);
    try {
      await ref.read(menuServiceProvider).createMenuItem(branchId, data);
      state = const MenuActionState();
      return true;
    } catch (e) {
      state = MenuActionState(error: e.toString());
      return false;
    }
  }

  Future<bool> updateItemDirect(
    String itemId,
    Map<String, dynamic> data, {
    MenuPricingRule? existingDiscount,
    Map<String, dynamic>? discount,
    bool discountEnabled = false,
  }) async {
    state = const MenuActionState(isLoading: true);
    try {
      final service = ref.read(menuServiceProvider);
      await service.updateMenuItem(itemId, data);

      if (discountEnabled && discount != null) {
        await service.upsertItemDiscount(
          itemId,
          existingRule: existingDiscount,
          discount: discount,
        );
      } else if (existingDiscount != null && existingDiscount.id.isNotEmpty) {
        await service.deactivateDiscount(existingDiscount.id);
      }

      state = const MenuActionState();
      return true;
    } catch (e) {
      state = MenuActionState(error: e.toString());
      return false;
    }
  }

  Future<bool> submitItemChangeRequest(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    state = const MenuActionState(isLoading: true);
    try {
      await ref.read(menuServiceProvider).submitItemChangeRequest(itemId, data);
      state = const MenuActionState();
      return true;
    } catch (e) {
      state = MenuActionState(error: e.toString());
      return false;
    }
  }

  Future<bool> toggleVisibility(String itemId, bool isVisible) async {
    try {
      await ref
          .read(menuServiceProvider)
          .toggleItemVisibility(itemId, isVisible);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleStock(String itemId, bool isInStock) async {
    try {
      await ref.read(menuServiceProvider).toggleItemStock(itemId, isInStock);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final menuNotifierProvider =
    NotifierProvider.autoDispose<MenuNotifier, MenuActionState>(
  MenuNotifier.new,
);
