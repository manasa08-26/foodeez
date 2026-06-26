import 'package:flutter/material.dart';

class AppAssets {
  AppAssets._();

  static const String partnerLight = 'assets/images/partner_light.png';
  static const String partnerDark = 'assets/images/partner_dark.png';

  /// Launcher icon output (generated from [partnerLight] via tool/generate_app_icon.dart).
  static const String partnerAppIcon = 'assets/images/partner_app_icon.png';

  static String partnerLogoFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? partnerDark
        : partnerLight;
  }
}
