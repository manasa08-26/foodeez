import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/loading_overlay.dart';

class RestaurantProfileScreen extends ConsumerStatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  ConsumerState<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState
    extends ConsumerState<RestaurantProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _ctrls = {};
  bool _isEditing = false;

  final _fields = [
    ('name', 'Restaurant Name', TextInputType.text),
    ('ownerName', 'Owner Name', TextInputType.text),
    ('email', 'Email', TextInputType.emailAddress),
    ('phone', 'Phone', TextInputType.phone),
    ('address', 'Address', TextInputType.multiline),
    ('city', 'City', TextInputType.text),
    ('state', 'State', TextInputType.text),
    ('brandDescription', 'Description', TextInputType.multiline),
  ];

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      _ctrls[f.$1] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _populateFields(dynamic restaurant) {
    final json = {
      'name': restaurant.name,
      'ownerName': restaurant.ownerName,
      'email': restaurant.email,
      'phone': restaurant.phone,
      'address': restaurant.address,
      'city': restaurant.city,
      'state': restaurant.state,
      'brandDescription': restaurant.brandDescription,
    };
    for (final f in _fields) {
      _ctrls[f.$1]?.text = json[f.$1] ?? '';
    }
  }

  Future<void> _save(String restaurantId) async {
    if (!_formKey.currentState!.validate()) return;
    final data = {for (final f in _fields) f.$1: _ctrls[f.$1]?.text ?? ''};
    final ok = await ref
        .read(restaurantUpdateProvider.notifier)
        .update(restaurantId, data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Restaurant updated!' : 'Update failed'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (ok) {
        setState(() => _isEditing = false);
        ref.invalidate(restaurantProvider(restaurantId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId == null) {
      return const Scaffold(
        body: Center(child: Text('No restaurant linked to this account')),
      );
    }

    final restaurantAsync = ref.watch(restaurantProvider(restaurantId));
    final updateState = ref.watch(restaurantUpdateProvider);
    final isUpdating = updateState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        //   title: const Text('Restaurant Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: restaurantAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (restaurant) {
          if (!_isEditing) {
            _populateFields(restaurant);
          }
          return LoadingOverlay(
            isLoading: isUpdating,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover photo banner
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          if (restaurant.coverPhotoUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                restaurant.coverPhotoUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          Positioned(
                            bottom: 12,
                            left: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (restaurant.cuisineTags.isNotEmpty)
                                  Text(
                                    restaurant.cuisineTags.take(3).join(', '),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Fields
                    ..._fields.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: AppTextField(
                            label: f.$2,
                            controller: _ctrls[f.$1],
                            keyboardType: f.$3,
                            maxLines: (f.$1 == 'address' ||
                                    f.$1 == 'brandDescription')
                                ? 3
                                : 1,
                            readOnly: !_isEditing,
                            validator: f.$1 == 'name'
                                ? (v) => v == null || v.isEmpty
                                    ? 'Name is required'
                                    : null
                                : null,
                          ),
                        )),
                    // Cuisine chips
                    if (restaurant.cuisineTags.isNotEmpty) ...[
                      const Text('Cuisine Tags',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: restaurant.cuisineTags
                            .map((t) => Chip(label: Text(t)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Cancel',
                              isOutlined: true,
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              label: 'Save Changes',
                              isLoading: isUpdating,
                              onPressed: () => _save(restaurantId),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
