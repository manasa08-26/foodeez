import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import 'partner_logo.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.adaptive;
    final accent = colors.primaryColor;

    return Column(
      children: [
        PartnerLogo.custom(
          width: compact ? 40 : 48,
          height: compact ? 40 : 48,
        ),
        SizedBox(height: compact ? 14 : 18),
        Text(
          'FooDeeZ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: compact ? 30 : 34,
            fontWeight: FontWeight.w900,
            color: accent,
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
            color: accent.withValues(alpha: 0.62),
            letterSpacing: 2.6,
          ),
        ),
      ],
    );
  }
}
