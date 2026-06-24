import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/status_badge.dart';

const _restaurantRoles = [
  'restaurant_admin',
  'restaurant_manager',
  'restaurant_staff',
];

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  void _showAddUserSheet(String restaurantId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddUserSheet(restaurantId: restaurantId),
    ).then((_) => ref.invalidate(restaurantUsersProvider(restaurantId)));
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId = ref.watch(restaurantIdProvider);
    if (restaurantId == null) {
      return const Center(child: Text('No restaurant linked'));
    }

    final usersAsync = ref.watch(restaurantUsersProvider(restaurantId));

    return Stack(
      children: [
        Positioned.fill(
          child: usersAsync.when(
        loading: () => const FullPageLoader(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (users) => users.isEmpty
            ? EmptyState(
                icon: Icons.people_outline,
                title: 'No team members',
                subtitle: 'Invite staff to manage your restaurant',
                actionLabel: 'Add Member',
                onAction: () => _showAddUserSheet(restaurantId),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final user = users[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primarySurface,
                          child: Text(
                            (user.displayName.isNotEmpty
                                    ? user.displayName[0]
                                    : 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.displayName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              Text(user.email,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        StatusBadge(
                            status: user.role.split('_').last.toUpperCase()),
                      ],
                    ),
                  );
                },
              ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 88,
          child: FloatingActionButton.extended(
            onPressed: () => _showAddUserSheet(restaurantId),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Add Member'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _AddUserSheet extends ConsumerStatefulWidget {
  final String restaurantId;
  const _AddUserSheet({required this.restaurantId});

  @override
  ConsumerState<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends ConsumerState<_AddUserSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _role = 'restaurant_staff';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(restaurantServiceProvider).createRestaurantUser(
        widget.restaurantId,
        {
          'displayName': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'role': _role,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Team member added!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Team Member',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Full Name',
              controller: _nameCtrl,
              prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.textHint, size: 18),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined,
                  color: AppColors.textHint, size: 18),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2)),
              ),
              items: _restaurantRoles
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r
                            .split('_')
                            .map((w) => w[0].toUpperCase() + w.substring(1))
                            .join(' ')),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Add Member',
              width: double.infinity,
              isLoading: _isLoading,
              onPressed: _submit,
              icon: Icons.person_add_rounded,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
