import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/menu_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_switch.dart';
import '../../widgets/app_text_field.dart';

bool _needsChangeApproval(String? role) =>
    role == 'restaurant_admin' || role == 'sales_operator';

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
  final _discountValueCtrl = TextEditingController();
  final _discountTitleCtrl = TextEditingController();
  final _changeDescCtrl = TextEditingController();

  String _selectedCategory = '';
  bool _isVisible = true;
  bool _isInStock = true;
  bool _discountEnabled = false;
  String _discountValueType = 'PERCENTAGE';
  DateTime? _discountEndsAt;
  MenuPricingRule? _existingDiscount;
  bool _loaded = false;
  bool _loadingEdit = false;

  bool get isEdit => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryId ?? '';
    if (isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingItem());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountValueCtrl.dispose();
    _discountTitleCtrl.dispose();
    _changeDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExistingItem() async {
    if (!isEdit || _loaded) return;
    setState(() => _loadingEdit = true);
    try {
      final categories =
          await ref.read(menuCategoriesProvider(widget.branchId).future);
      final item = findMenuItem(categories, widget.itemId!);
      if (item == null || !mounted) return;

      _nameCtrl.text = item.name;
      _descCtrl.text = item.description ?? '';
      _priceCtrl.text = item.price.toStringAsFixed(
        item.price % 1 == 0 ? 0 : 2,
      );
      _selectedCategory = item.categoryId;
      _isVisible = item.isVisible;
      _isInStock = item.isInStock;

      final discount = item.activeDiscount;
      _existingDiscount = discount;
      if (discount != null) {
        _discountEnabled = true;
        _discountValueType = discount.valueType;
        _discountValueCtrl.text = discount.value.toString();
        _discountTitleCtrl.text = discount.title ?? '';
        if (discount.endsAt != null && discount.endsAt!.isNotEmpty) {
          _discountEndsAt = DateTime.tryParse(discount.endsAt!);
        }
      }
      _loaded = true;
    } finally {
      if (mounted) setState(() => _loadingEdit = false);
    }
  }

  Map<String, dynamic>? _buildDiscountPayload() {
    if (!_discountEnabled) return null;
    final value = double.tryParse(_discountValueCtrl.text.trim()) ?? 0;
    if (value <= 0) return null;
    return {
      'valueType': _discountValueType,
      'value': value,
      if (_discountTitleCtrl.text.trim().isNotEmpty)
        'title': _discountTitleCtrl.text.trim(),
      if (_discountEndsAt != null)
        'endsAt': _discountEndsAt!.toIso8601String().split('T').first,
    };
  }

  Future<void> _showSuccessAlert(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Success',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final role = ref.read(currentUserProvider)?.role;
    final data = {
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': double.tryParse(_priceCtrl.text.trim()) ?? 0,
      'currency': 'INR',
      'categoryId': _selectedCategory,
      if (!isEdit) ...{
        'isVisible': _isVisible,
        'isInStock': _isInStock,
      },
    };

    final discount = _buildDiscountPayload();
    bool ok = false;
    String successMessage = '';

    if (isEdit) {
      if (_needsChangeApproval(role)) {
        if (_changeDescCtrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please provide a reason for this change.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final payload = {
          'changeDescription': _changeDescCtrl.text.trim(),
          ...data,
        };
        if (discount != null) payload['discount'] = discount;
        ok = await ref
            .read(menuNotifierProvider.notifier)
            .submitItemChangeRequest(widget.itemId!, payload);
        successMessage = 'Change request submitted for super-admin approval.';
      } else {
        ok = await ref.read(menuNotifierProvider.notifier).updateItemDirect(
              widget.itemId!,
              data,
              existingDiscount: _existingDiscount,
              discount: discount,
              discountEnabled: discount != null,
            );
        successMessage = 'Menu item updated successfully.';
      }
    } else {
      final createData = Map<String, dynamic>.from(data);
      if (discount != null) createData['discount'] = discount;
      ok = await ref
          .read(menuNotifierProvider.notifier)
          .createItem(widget.branchId, createData);
      successMessage = 'Menu item added successfully.';
    }

    if (!mounted) return;

    if (ok) {
      ref.invalidate(menuCategoriesProvider(widget.branchId));
      if (isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(successMessage),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        context.go('/branches/${widget.branchId}/menu');
      } else {
        await _showSuccessAlert(successMessage);
        if (mounted) context.go('/branches/${widget.branchId}/menu');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save menu item'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _pickDiscountEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _discountEndsAt ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _discountEndsAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final categoriesAsync = ref.watch(menuCategoriesProvider(widget.branchId));
    final menuState = ref.watch(menuNotifierProvider);
    final role = ref.watch(currentUserProvider)?.role;
    final needsApproval = isEdit && _needsChangeApproval(role);

    if (_loadingEdit) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
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
                children: [
                  AppTextField(
                    label: 'Item Name',
                    controller: _nameCtrl,
                    hint: 'e.g. Chicken Keema Biryani (Serve 2)',
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                  categoriesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (cats) => DropdownButtonFormField<String>(
                      value:
                          _selectedCategory.isEmpty ? null : _selectedCategory,
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
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2)),
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
                  if (!isEdit) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text('Visible',
                                  style: TextStyle(fontSize: 13)),
                              AppSwitch(
                                value: _isVisible,
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
                              AppSwitch(
                                value: _isInStock,
                                onChanged: (v) =>
                                    setState(() => _isInStock = v),
                                onColor: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  _DiscountSection(
                    enabled: _discountEnabled,
                    valueType: _discountValueType,
                    valueController: _discountValueCtrl,
                    titleController: _discountTitleCtrl,
                    endsAt: _discountEndsAt,
                    onToggle: () =>
                        setState(() => _discountEnabled = !_discountEnabled),
                    onValueTypeChanged: (v) =>
                        setState(() => _discountValueType = v),
                    onPickEndDate: _pickDiscountEndDate,
                  ),
                  if (needsApproval) ...[
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Reason for change',
                      controller: _changeDescCtrl,
                      hint: 'Explain why this update is needed',
                      maxLines: 2,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Reason is required for approval'
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: isEdit
                  ? (needsApproval ? 'Submit for Approval' : 'Update Item')
                  : 'Add Item',
              width: double.infinity,
              isLoading: menuState.isLoading,
              onPressed: _submit,
              icon: isEdit ? Icons.save_rounded : Icons.add_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscountSection extends StatelessWidget {
  const _DiscountSection({
    required this.enabled,
    required this.valueType,
    required this.valueController,
    required this.titleController,
    required this.endsAt,
    required this.onToggle,
    required this.onValueTypeChanged,
    required this.onPickEndDate,
  });

  final bool enabled;
  final String valueType;
  final TextEditingController valueController;
  final TextEditingController titleController;
  final DateTime? endsAt;
  final VoidCallback onToggle;
  final ValueChanged<String> onValueTypeChanged;
  final VoidCallback onPickEndDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Discount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: onToggle,
              child: Text(enabled ? 'Remove discount' : 'Add discount'),
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: valueType,
            decoration: InputDecoration(
              labelText: 'Discount type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'PERCENTAGE',
                child: Text('Percentage (%)'),
              ),
              DropdownMenuItem(value: 'FLAT', child: Text('Flat amount (₹)')),
            ],
            onChanged: (v) {
              if (v != null) onValueTypeChanged(v);
            },
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: valueType == 'PERCENTAGE'
                ? 'Discount %'
                : 'Discount amount (₹)',
            controller: valueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Discount title (optional)',
            controller: titleController,
            hint: 'Weekend sale',
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onPickEndDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Valid until (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(
                endsAt != null
                    ? '${endsAt!.year}-${endsAt!.month.toString().padLeft(2, '0')}-${endsAt!.day.toString().padLeft(2, '0')}'
                    : 'Select date',
                style: TextStyle(
                  color: endsAt != null ? colors.textPrimary : colors.textHint,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
