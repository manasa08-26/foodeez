import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';

class SplashReadyNotifier extends Notifier<bool> {
  Timer? _timer;

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    _timer = Timer(AppConstants.splashDuration, () {
      state = true;
    });
    return false;
  }
}

final splashReadyProvider =
    NotifierProvider<SplashReadyNotifier, bool>(SplashReadyNotifier.new);
