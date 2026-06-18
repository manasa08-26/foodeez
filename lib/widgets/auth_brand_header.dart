import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    this.logoSize = 88,
    this.compact = false,
  });

  final double logoSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(compact ? 22 : 26),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            AppAssets.profileLogo,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        Text(
          'FooDeeZ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: compact ? 30 : 34,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: -0.8,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'RESTAURANT PARTNER PORTAL',
          style: GoogleFonts.plusJakartaSans(
            fontSize: compact ? 10.5 : 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary.withValues(alpha: 0.62),
            letterSpacing: 2.6,
          ),
        ),
      ],
    );
  }
}
