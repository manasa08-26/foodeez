import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

Future<void> showMenuRestrictedToggleDialog(
  BuildContext context, {
  required String field,
  required String itemName,
}) {
  final label = field == 'isVisible' ? 'visibility' : 'stock status';
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Action restricted',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: Text(
        'Only a super admin can change the $label for $itemName.',
        style: const TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

bool isSuperAdminRole(String? role) => role == 'super_admin';

bool itemToggleRequiresApproval(String? role) => !isSuperAdminRole(role);
