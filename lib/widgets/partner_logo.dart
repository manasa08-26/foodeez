import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';

/// Change logo display sizes here — used across the whole app.
abstract final class PartnerLogoSizes {
  static const double appBar = 22;
  static const double auth = 36;
  static const double authCompact = 32;
  static const double splash = 56;
}

/// Theme-aware partner logo: [AppAssets.partnerLight] in light mode,
/// [AppAssets.partnerDark] in dark mode.
class PartnerLogo extends StatelessWidget {
  const PartnerLogo.appBar({super.key, this.asset})
      : width = PartnerLogoSizes.appBar,
        height = PartnerLogoSizes.appBar;

  const PartnerLogo.auth({super.key, bool compact = false, this.asset})
      : width = compact ? PartnerLogoSizes.authCompact : PartnerLogoSizes.auth,
        height = compact ? PartnerLogoSizes.authCompact : PartnerLogoSizes.auth;

  const PartnerLogo.splash({super.key, this.asset})
      : width = PartnerLogoSizes.splash,
        height = PartnerLogoSizes.splash;

  const PartnerLogo.custom({
    super.key,
    required this.width,
    required this.height,
    this.asset,
  });

  final double width;
  final double height;

  /// Optional override; defaults to light/dark partner logo from theme.
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final logoAsset = asset ?? AppAssets.partnerLogoFor(context);
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Image.asset(
          logoAsset,
          width: width,
          height: height,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
