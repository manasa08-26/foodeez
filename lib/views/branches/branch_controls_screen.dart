import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/loading_overlay.dart';

class BranchControlsScreen extends ConsumerStatefulWidget {
  final String branchId;
  const BranchControlsScreen({super.key, required this.branchId});

  @override
  ConsumerState<BranchControlsScreen> createState() =>
      _BranchControlsScreenState();
}

class _BranchControlsScreenState extends ConsumerState<BranchControlsScreen> {
  final _openCtrl = TextEditingController();
  final _closeCtrl = TextEditingController();
  bool _isOnline = false;
  bool _busyMode = false;
  bool _temporaryClosure = false;
  bool _populated = false;

  @override
  void dispose() {
    _openCtrl.dispose();
    _closeCtrl.dispose();
    super.dispose();
  }

  void _populate(dynamic branch) {
    if (!_populated) {
      _openCtrl.text = branch.openingTime ?? '';
      _closeCtrl.text = branch.closingTime ?? '';
      _isOnline = branch.isOnline;
      _busyMode = branch.busyMode;
      _temporaryClosure = branch.temporaryClosure;
      _populated = true;
    }
  }

  Future<void> _save(String restaurantId) async {
    final ok = await ref.read(branchControlsProvider.notifier).updateControls(
      restaurantId,
      widget.branchId,
      {
        'openingTime': _openCtrl.text.trim(),
        'closingTime': _closeCtrl.text.trim(),
        'isOnline': _isOnline,
        'busyMode': _busyMode,
        'temporaryClosure': _temporaryClosure,
      },
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Changes saved successfully' : 'Failed to save changes',
          ),
          backgroundColor: ok ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (ok) {
        ref.invalidate(branchProvider((restaurantId, widget.branchId)));
        ref.invalidate(branchesProvider(restaurantId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final restaurantId = ref.watch(restaurantIdProvider) ?? '';
    final branchAsync =
        ref.watch(branchProvider((restaurantId, widget.branchId)));
    final controlsState = ref.watch(branchControlsProvider);
    final isControlsLoading = controlsState.isLoading;

    return branchAsync.when(
      loading: () => const FullPageLoader(),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (branch) {
        _populate(branch);
        return LoadingOverlay(
          isLoading: isControlsLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ToggleRow(
                        title: 'Online',
                        subtitle: 'Accept new orders',
                        value: _isOnline,
                        activeThumbColor: AppColors.success,
                        onChanged: (v) => setState(() => _isOnline = v),
                      ),
                      Divider(height: 16, color: colors.cardBorder),
                      _ToggleRow(
                        title: 'Busy Mode',
                        subtitle: 'Pause delivery, only pickup',
                        value: _busyMode,
                        activeThumbColor: AppColors.warning,
                        onChanged: (v) => setState(() => _busyMode = v),
                      ),
                      Divider(height: 16, color: colors.cardBorder),
                      _ToggleRow(
                        title: 'Temporary Closure',
                        subtitle: 'Temporarily close this branch',
                        value: _temporaryClosure,
                        activeThumbColor: AppColors.error,
                        onChanged: (v) =>
                            setState(() => _temporaryClosure = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operating Hours',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Opening',
                              controller: _openCtrl,
                              prefixIcon: Icon(
                                Icons.wb_sunny_outlined,
                                color: colors.textHint,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Closing',
                              controller: _closeCtrl,
                              prefixIcon: Icon(
                                Icons.nightlight_outlined,
                                color: colors.textHint,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save Changes',
                  width: double.infinity,
                  isLoading: isControlsLoading,
                  onPressed: () => _save(restaurantId),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Color activeThumbColor;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeThumbColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppSwitch(
          value: value,
          onColor: activeThumbColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
