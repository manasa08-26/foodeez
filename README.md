# Foodeez Flutter — Restaurant Admin App

Flutter mobile app for `restaurant_admin` role only. Purple & white theme, MVC architecture.

## Architecture

```
lib/
├── main.dart               ← Entry point (Riverpod ProviderScope)
├── app.dart                ← MaterialApp.router with go_router
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       ← All purple/white design tokens
│   │   └── app_constants.dart    ← API base URL, endpoints, role constants
│   ├── theme/
│   │   └── app_theme.dart        ← ThemeData (Material 3, Poppins font)
│   ├── network/
│   │   └── api_client.dart       ← Dio instance + Riverpod provider + ApiException
│   ├── storage/
│   │   └── local_storage.dart    ← FlutterSecureStorage token management
│   └── utils/
│       ├── crypto_utils.dart     ← AES-CBC password encryption (matches web)
│       ├── jwt_utils.dart        ← JWT decode, expiry check, role extraction
│       └── formatters.dart       ← Currency, date/time, order status formatters
├── models/                 ← Plain Dart models parsed from API JSON
│   ├── user_model.dart
│   ├── restaurant_model.dart
│   ├── branch_model.dart
│   ├── menu_model.dart
│   ├── order_model.dart
│   ├── settlement_model.dart
│   ├── document_model.dart
│   └── dashboard_model.dart
├── services/               ← API calls (Dio) — one file per domain
│   ├── auth_service.dart
│   ├── restaurant_service.dart
│   ├── branch_service.dart
│   ├── menu_service.dart
│   ├── order_service.dart
│   ├── settlement_service.dart
│   └── document_service.dart
├── providers/              ← Riverpod StateNotifier + FutureProvider per domain
│   ├── auth_provider.dart
│   ├── restaurant_provider.dart
│   ├── branch_provider.dart
│   ├── menu_provider.dart
│   ├── order_provider.dart
│   ├── settlement_provider.dart
│   └── document_provider.dart
├── router/
│   └── app_router.dart     ← GoRouter with auth redirect + ShellRoute
├── widgets/                ← Reusable widget library
│   ├── shell_scaffold.dart       ← App shell with drawer nav
│   ├── app_button.dart
│   ├── app_text_field.dart
│   ├── stat_card.dart
│   ├── status_badge.dart
│   ├── empty_state.dart
│   ├── confirmation_dialog.dart
│   └── loading_overlay.dart
└── views/                  ← Screens (one folder per feature)
    ├── auth/
    │   ├── login_screen.dart
    │   └── forgot_password_screen.dart
    ├── dashboard/
    │   └── dashboard_screen.dart
    ├── restaurant/
    │   ├── restaurant_profile_screen.dart
    │   └── onboarding_screen.dart
    ├── branches/
    │   ├── branches_screen.dart
    │   ├── branch_detail_screen.dart
    │   ├── branch_controls_screen.dart
    │   └── create_branch_screen.dart
    ├── menu/
    │   ├── menu_screen.dart
    │   ├── category_form_screen.dart
    │   └── menu_item_form_screen.dart
    ├── orders/
    │   ├── orders_screen.dart
    │   └── order_detail_screen.dart
    ├── kds/
    │   └── kds_screen.dart
    ├── settlement/
    │   └── settlement_screen.dart
    ├── documents/
    │   └── documents_screen.dart
    └── users/
        └── users_screen.dart
```

## Screens (restaurant_admin only)

| Screen | Route | Description |
|--------|-------|-------------|
| Login | `/login` | Email + AES-encrypted password auth |
| Forgot Password | `/forgot-password` | Request reset link |
| Dashboard | `/dashboard` | Revenue charts, stats, quick actions |
| Restaurant Profile | `/restaurant` | View/edit restaurant details |
| Onboarding | `/restaurant/onboarding` | 5-step onboarding tracker |
| Branches | `/branches` | List branches, toggle online |
| Create Branch | `/branches/new` | Add new branch |
| Branch Detail | `/branches/:id` | Navigate to menu/controls |
| Menu | `/branches/:id/menu` | Categories + items CRUD |
| Category Form | `/branches/:id/menu/category/new` | Add/edit category |
| Menu Item Form | `/branches/:id/menu/item/new` | Add/edit menu item |
| Branch Controls | `/branches/:id/controls` | Hours, online toggle, busy mode |
| Orders | `/orders` | Orders list with status filter |
| Order Detail | `/orders/:id` | Full order info + accept/reject |
| KDS | `/kds` | Live kitchen display (WebSocket) |
| Settlement | `/settlement` | Daily commission breakdown |
| Documents | `/documents` | Upload & track verification |
| Team | `/users` | Add/view restaurant team members |

## Setup

```bash
cd foodeez_flutter
flutter pub get
```

Set API base URL in `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_API_HOST:3001/api/v1';
```

```bash
flutter run
```

## Key Tech Stack

| Concern | Package |
|---------|---------|
| Navigation | `go_router` |
| State | `flutter_riverpod` |
| HTTP | `dio` |
| Secure storage | `flutter_secure_storage` |
| Charts | `fl_chart` |
| Fonts | `google_fonts` (Poppins) |
| Real-time | `socket_io_client` |
| Files | `file_picker` |
| Crypto | `encrypt` (AES-CBC) |
