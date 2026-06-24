import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_switch.dart';
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
  bool _loaded = false;
  bool _loadingEdit = false;

  bool get isEdit => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategory());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategory() async {
    if (!isEdit || _loaded) return;
    setState(() => _loadingEdit = true);
    try {
      final categories =
          await ref.read(menuCategoriesProvider(widget.branchId).future);
      final category = findMenuCategory(categories, widget.categoryId!);
      if (category == null || !mounted) return;

      _nameCtrl.text = category.name;
      _displayNameCtrl.text = category.displayName ?? '';
      _isVisible = category.isVisible;
      _loaded = true;
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

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
        content: Text(
          ok
              ? (isEdit
                  ? 'Category updated successfully'
                  : 'Category created successfully')
              : 'Failed to save category',
        ),
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
    final colors = context.adaptive;
    final menuState = ref.watch(menuNotifierProvider);

    if (_loadingEdit) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Container(
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
                  Text(
                    'Visible to customers',
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                  ),
                  AppSwitch(
                    value: _isVisible,
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
