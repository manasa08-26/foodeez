import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CreateBranchScreen extends ConsumerStatefulWidget {
  const CreateBranchScreen({super.key});

  @override
  ConsumerState<CreateBranchScreen> createState() => _CreateBranchScreenState();
}

class _CreateBranchScreenState extends ConsumerState<CreateBranchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _openCtrl = TextEditingController(text: '09:00');
  final _closeCtrl = TextEditingController(text: '22:00');

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _addressCtrl,
      _cityCtrl,
      _stateCtrl,
      _zipCtrl,
      _openCtrl,
      _closeCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final restaurantId = ref.read(restaurantIdProvider);
    if (restaurantId == null) return;

    final ok = await ref.read(branchControlsProvider.notifier).createBranch(
          restaurantId,
          {
            'name': _nameCtrl.text.trim(),
            'address': _addressCtrl.text.trim(),
            'city': _cityCtrl.text.trim(),
            'state': _stateCtrl.text.trim(),
            'zipCode': _zipCtrl.text.trim(),
            'latitude': 0,
            'longitude': 0,
            'openingTime': _openCtrl.text.trim(),
            'closingTime': _closeCtrl.text.trim(),
            'isOnline': false,
          },
        );

    if (!mounted) return;

    final error = ref.read(branchControlsProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Branch created successfully' : (error ?? 'Failed to create branch'),
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (ok) {
      ref.invalidate(branchesProvider(restaurantId));
      context.go('/branches');
    }
  }

  @override
  Widget build(BuildContext context) {
    final branchState = ref.watch(branchControlsProvider);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section('Branch Information', [
                AppTextField(
                  label: 'Branch Name',
                  controller: _nameCtrl,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                  prefixIcon: const Icon(Icons.store_mall_directory_rounded,
                      color: AppColors.textHint, size: 20),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Address',
                  controller: _addressCtrl,
                  maxLines: 2,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Address is required' : null,
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: AppColors.textHint, size: 20),
                ),
              ]),
              const SizedBox(height: 16),
              _Section('Location', [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'City',
                        controller: _cityCtrl,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'City is required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'State',
                        controller: _stateCtrl,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'State is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'ZIP / Pincode',
                  controller: _zipCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'ZIP is required' : null,
                ),
              ]),
              const SizedBox(height: 16),
              _Section('Operating Hours', [
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Opening Time',
                        controller: _openCtrl,
                        hint: '09:00',
                        prefixIcon: const Icon(Icons.wb_sunny_outlined,
                            color: AppColors.textHint, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Closing Time',
                        controller: _closeCtrl,
                        hint: '22:00',
                        prefixIcon: const Icon(Icons.nightlight_outlined,
                            color: AppColors.textHint, size: 20),
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 24),
              AppButton(
                label: 'Create Branch',
                width: double.infinity,
                onPressed: _submit,
                isLoading: branchState.isLoading,
                icon: Icons.add_business_rounded,
              ),
            ],
          ),
        ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
