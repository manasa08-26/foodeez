import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';
import '../views/splash/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/forgot_password_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/restaurant/restaurant_profile_screen.dart';
import '../views/restaurant/onboarding_screen.dart';
import '../views/branches/branches_screen.dart';
import '../views/branches/branch_detail_screen.dart';
import '../views/branches/branch_controls_screen.dart';
import '../views/branches/create_branch_screen.dart';
import '../views/menu/menu_screen.dart';
import '../views/menu/menu_item_form_screen.dart';
import '../views/menu/category_form_screen.dart';
import '../views/orders/orders_screen.dart';
import '../views/orders/order_detail_screen.dart';
import '../views/kds/kds_screen.dart';
import '../views/settlement/settlement_screen.dart';
import '../views/documents/documents_screen.dart';
import '../views/users/users_screen.dart';
import '../widgets/shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final loc = state.matchedLocation;
      final isPublic = loc == '/splash' ||
          loc == '/login' ||
          loc == '/forgot-password';

      debugPrint(
          '[Router] redirect isAuth=$isAuth isLoading=$isLoading uri=${state.uri} matched=$loc');

      // Let splash handle its own navigation
      if (loc == '/splash') return null;
      if (isLoading) return null;
      if (!isAuth && !isPublic) return '/login';
      if (isAuth && (loc == '/login' || loc == '/forgot-password')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/restaurant',
            name: 'restaurant',
            builder: (_, __) => const RestaurantProfileScreen(),
          ),
          GoRoute(
            path: '/restaurant/onboarding',
            name: 'onboarding',
            builder: (_, __) => const OnboardingScreen(),
          ),
          GoRoute(
            path: '/branches',
            name: 'branches',
            builder: (_, __) => const BranchesScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'create-branch',
                builder: (_, __) => const CreateBranchScreen(),
              ),
              GoRoute(
                path: ':branchId',
                name: 'branch-detail',
                builder: (_, state) => BranchDetailScreen(
                    branchId: state.pathParameters['branchId']!),
                routes: [
                  GoRoute(
                    path: 'menu',
                    name: 'menu',
                    builder: (_, state) =>
                        MenuScreen(branchId: state.pathParameters['branchId']!),
                    routes: [
                      GoRoute(
                        path: 'category/new',
                        name: 'category-new',
                        builder: (_, state) => CategoryFormScreen(
                            branchId: state.pathParameters['branchId']!),
                      ),
                      GoRoute(
                        path: 'category/:categoryId/edit',
                        name: 'category-edit',
                        builder: (_, state) => CategoryFormScreen(
                          branchId: state.pathParameters['branchId']!,
                          categoryId: state.pathParameters['categoryId'],
                        ),
                      ),
                      GoRoute(
                        path: 'item/new',
                        name: 'item-new',
                        builder: (_, state) => MenuItemFormScreen(
                          branchId: state.pathParameters['branchId']!,
                          categoryId: state.uri.queryParameters['categoryId'],
                        ),
                      ),
                      GoRoute(
                        path: 'item/:itemId/edit',
                        name: 'item-edit',
                        builder: (_, state) => MenuItemFormScreen(
                          branchId: state.pathParameters['branchId']!,
                          itemId: state.pathParameters['itemId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'controls',
                    name: 'branch-controls',
                    builder: (_, state) => BranchControlsScreen(
                        branchId: state.pathParameters['branchId']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (_, __) => const OrdersScreen(),
            routes: [
              GoRoute(
                path: ':orderId',
                name: 'order-detail',
                builder: (_, state) => OrderDetailScreen(
                    orderId: state.pathParameters['orderId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/kds',
            name: 'kds',
            builder: (_, __) => const KdsScreen(),
          ),
          GoRoute(
            path: '/settlement',
            name: 'settlement',
            builder: (_, __) => const SettlementScreen(),
          ),
          GoRoute(
            path: '/documents',
            name: 'documents',
            builder: (_, __) => const DocumentsScreen(),
          ),
          GoRoute(
            path: '/users',
            name: 'users',
            builder: (_, __) => const UsersScreen(),
          ),
        ],
      ),
    ],
  );
});
