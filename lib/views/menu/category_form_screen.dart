import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final String branchId;
  final String? categoryId;

  const CategoryFormScreen({
    super.key,
    required this.branchId,
    this.categoryId,
  });

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  bool _isVisible = true;

  bool get isEdit => widget.categoryId != null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameCtrl.text.trim(),
      'displayName': _displayNameCtrl.text.trim(),
      'isVisible': _isVisible,
    };

    bool ok;
    if (isEdit) {
      ok = await ref
          .read(menuNotifierProvider.notifier)
          .updateCategory(widget.categoryId!, data);
    } else {
      ok = await ref
          .read(menuNotifierProvider.notifier)
          .createCategory(widget.branchId, data);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Category saved!' : 'Failed to save'),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      if (ok) {
        ref.invalidate(menuCategoriesProvider(widget.branchId));
        context.go('/branches/${widget.branchId}/menu');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuNotifierProvider);

    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                AppTextField(
                  label: 'Category Name (internal)',
                  controller: _nameCtrl,
                  hint: 'e.g. starters',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Display Name (customer facing)',
                  controller: _displayNameCtrl,
                  hint: 'e.g. Starters & Soups',
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Visible to customers',
                        style: TextStyle(fontSize: 14)),
                    Switch(
                      value: _isVisible,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isVisible = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: isEdit ? 'Update Category' : 'Create Category',
                  width: double.infinity,
                  isLoading: menuState.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
    );
  }
}
