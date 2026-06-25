import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';

/// Change logo display sizes here — used across the whole app.
abstract final class PartnerLogoSizes {
  static const double appBar = 22;
  static const double auth = 36;
  static const double authCompact = 32;
  static const double splash = 56;
}

/// Shared partner logo with consistent sizing and center alignment.
class PartnerLogo extends StatelessWidget {
  const PartnerLogo.appBar({super.key})
      : width = PartnerLogoSizes.appBar,
        height = PartnerLogoSizes.appBar;

  const PartnerLogo.auth({super.key, bool compact = false})
      : width = compact ? PartnerLogoSizes.authCompact : PartnerLogoSizes.auth,
        height = compact ? PartnerLogoSizes.authCompact : PartnerLogoSizes.auth;

  const PartnerLogo.splash({super.key})
      : width = PartnerLogoSizes.splash,
        height = PartnerLogoSizes.splash;

  const PartnerLogo.custom({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Image.asset(
          AppAssets.partnerLogo,
          width: width,
          height: height,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
