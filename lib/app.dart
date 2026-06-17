import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class FoodeezApp extends ConsumerWidget {
  const FoodeezApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Foodeez Restaurant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      backButtonDispatcher: _FoodeezBackButtonDispatcher(router),
    );
  }
}

class _FoodeezBackButtonDispatcher extends RootBackButtonDispatcher {
  _FoodeezBackButtonDispatcher(this.router);

  final GoRouter router;

  @override
  Future<bool> didPopRoute() async {
    final path = router.routeInformationProvider.value.uri.path;

    // Never let Android hardware back close the app from app screens.
    if (path != '/dashboard') {
      router.go('/dashboard');
    }
    return true;
  }
}
