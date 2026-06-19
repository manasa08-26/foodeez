import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';

final branchesProvider = FutureProvider.autoDispose
    .family<List<BranchModel>, String>((ref, restaurantId) async {
  return ref.read(branchServiceProvider).getBranches(restaurantId);
});

final branchProvider = FutureProvider.autoDispose
    .family<BranchModel, (String, String)>((ref, args) async {
  final (restaurantId, branchId) = args;
  return ref.read(branchServiceProvider).getBranch(restaurantId, branchId);
});

// Branch action state
class BranchActionState {
  final bool isLoading;
  final BranchModel? data;
  final String? error;
  const BranchActionState({this.isLoading = false, this.data, this.error});
}

class BranchControlsNotifier extends Notifier<BranchActionState> {
  @override
  BranchActionState build() => const BranchActionState();

  Future<bool> toggleOnline(
      String restaurantId, String branchId, bool isOnline) async {
    state = const BranchActionState(isLoading: true);
    try {
      final updated = await ref
          .read(branchServiceProvider)
          .toggleOnline(restaurantId, branchId, isOnline);
      if (!ref.mounted) return true;
      state = BranchActionState(data: updated);
      // Refresh branch list and specific branch cache so UI updates immediately
      ref.invalidate(branchesProvider(restaurantId));
      ref.invalidate(branchProvider((restaurantId, branchId)));
      return true;
    } catch (e) {
      if (ref.mounted) state = BranchActionState(error: e.toString());
      return false;
    }
  }

  Future<bool> updateControls(String restaurantId, String branchId,
      Map<String, dynamic> controls) async {
    state = const BranchActionState(isLoading: true);
    try {
      final updated = await ref
          .read(branchServiceProvider)
          .updateControls(restaurantId, branchId, controls);
      if (!ref.mounted) return true;
      state = BranchActionState(data: updated);
      return true;
    } catch (e) {
      if (ref.mounted) state = BranchActionState(error: e.toString());
      return false;
    }
  }

  Future<bool> createBranch(
      String restaurantId, Map<String, dynamic> data) async {
    state = const BranchActionState(isLoading: true);
    try {
      final branch = await ref
          .read(branchServiceProvider)
          .createBranch(restaurantId, data);
      if (!ref.mounted) return true;
      state = BranchActionState(data: branch);
      return true;
    } catch (e) {
      if (ref.mounted) state = BranchActionState(error: e.toString());
      return false;
    }
  }
}

final branchControlsProvider =
    NotifierProvider.autoDispose<BranchControlsNotifier, BranchActionState>(
  BranchControlsNotifier.new,
);
