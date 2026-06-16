import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

String _deriveNameFromEmail(String email) {
  final local = email.split('@').first;
  final parts = local.split(RegExp(r'[._\-]')).where((s) => s.isNotEmpty);
  final mapped = parts.map((p) =>
      p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}');
  final name = mapped.join(' ');
  return name.isNotEmpty ? name : email;
}

class AuthState {
  final AuthUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    debugPrint('[AuthNotifier] build() init');
    _init();
    return const AuthState(isLoading: true);
  }

  Future<void> _init() async {
    final user = await ref.read(authServiceProvider).getStoredUser();
    debugPrint('[AuthNotifier] _init stored user=${user?.email}');
    if (user != null) {
      // Try to fetch fresh profile to get proper displayName
      try {
        final profile = await ref.read(authServiceProvider).getMe();
        final enriched = AuthUser(
          token: user.token,
          role: user.role,
          email: user.email,
          displayName: profile.displayName.isNotEmpty
              ? profile.displayName
              : (user.displayName.contains('@')
                  ? _deriveNameFromEmail(user.email)
                  : user.displayName),
          restaurantId: profile.restaurantId ?? user.restaurantId,
        );
        state = AuthState(user: enriched);
        debugPrint(
            '[AuthNotifier] _init enriched user=${enriched.displayName}');
        return;
      } catch (e) {
        debugPrint('[AuthNotifier] _init profile fetch failed: $e');
      }
    }
    state = AuthState(user: user);
  }

  Future<bool> login(String email, String password) async {
    debugPrint('[AuthNotifier] login start email=$email');
    state = state.copyWith(isLoading: true, error: null);
    try {
      var user = await ref.read(authServiceProvider).login(email, password);
      debugPrint('[AuthNotifier] login success user=${user.email}');
      // Fetch profile to get displayName if backend provides it
      try {
        final profile = await ref.read(authServiceProvider).getMe();
        user = AuthUser(
          token: user.token,
          role: user.role,
          email: user.email,
          displayName: profile.displayName.isNotEmpty
              ? profile.displayName
              : (user.displayName.contains('@')
                  ? _deriveNameFromEmail(user.email)
                  : user.displayName),
          restaurantId: profile.restaurantId ?? user.restaurantId,
        );
        debugPrint('[AuthNotifier] login enriched user=${user.displayName}');
      } catch (e) {
        debugPrint('[AuthNotifier] login profile fetch failed: $e');
      }
      state = AuthState(user: user);
      return true;
    } catch (e) {
      debugPrint('[AuthNotifier] login error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(error: null);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});

final restaurantIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.restaurantId;
});
