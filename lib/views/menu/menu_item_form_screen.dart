import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class MenuItemFormScreen extends ConsumerStatefulWidget {
  final String branchId;
  final String? itemId;
  final String? categoryId;

  const MenuItemFormScreen({
    super.key,
    required this.branchId,
    this.itemId,
    this.categoryId,
  });

  @override
  ConsumerState<MenuItemFormScreen> createState() => _MenuItemFormScreenState();
}

class _MenuItemFormScreenState extends ConsumerState<MenuItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedCategory = '';
  bool _isVisible = true;
  bool _isInStock = true;

  bool get isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryId ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'currency': 'INR',
      'categoryId': _selectedCategory,
      'isVisible': _isVisible,
      'isInStock': _isInStock,
    };

    bool ok;
    if (isEdit) {
      ok = await ref
          .read(menuNotifierProvider.notifier)
          .updateItem(widget.itemId!, data);
    } else {
      ok = await ref
          .read(menuNotifierProvider.notifier)
          .createItem(widget.branchId, data);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Item saved!' : 'Failed to save'),
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
    final categoriesAsync =
        ref.watch(menuCategoriesProvider(widget.branchId));
    final menuState = ref.watch(menuNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar:
          AppBar(title: Text(isEdit ? 'Edit Menu Item' : 'New Menu Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Item Name',
                      controller: _nameCtrl,
                      hint: 'e.g. Butter Chicken',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Description',
                      controller: _descCtrl,
                      hint: 'Brief description of the item',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Price (₹)',
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      prefixIcon: const Icon(Icons.currency_rupee_rounded,
                          color: AppColors.textHint, size: 18),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Price is required';
                        if (double.tryParse(v) == null) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    // Category picker
                    categoriesAsync.when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (cats) => DropdownButtonFormField<String>(
                        initialValue: _selectedCategory.isEmpty
                            ? null
                            : _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.primary, width: 2)),
                        ),
                        items: cats
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.displayName ?? c.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategory = v ?? ''),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Select a category' : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Visible',
                                  style: TextStyle(fontSize: 13)),
                              Switch(
                                value: _isVisible,
                                activeThumbColor: AppColors.primary,
                                onChanged: (v) =>
                                    setState(() => _isVisible = v),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text('In Stock',
                                  style: TextStyle(fontSize: 13)),
                              Switch(
                                value: _isInStock,
                                activeThumbColor: AppColors.success,
                                onChanged: (v) =>
                                    setState(() => _isInStock = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: isEdit ? 'Update Item' : 'Add Item',
                width: double.infinity,
                isLoading: menuState.isLoading,
                onPressed: _submit,
                icon: isEdit ? Icons.save_rounded : Icons.add_circle_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
