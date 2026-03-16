/// 테스트 전용 앱 위젯.
/// Firebase, FCM, 백그라운드 위치 등 네이티브 의존성 없이 앱 UI만 실행한다.
/// 매 테스트마다 새 GoRouter 인스턴스를 생성하여 라우트 상태를 격리한다.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:itto/core/theme/app_theme.dart';
import 'package:itto/presentation/splash/screens/splash_screen.dart';
import 'package:itto/presentation/auth/screens/login_screen.dart';
import 'package:itto/presentation/auth/screens/signup/signup_flow_screen.dart';
import 'package:itto/presentation/auth/screens/verification_pending_screen.dart';
import 'package:itto/presentation/auth/screens/verification_rejected_screen.dart';
import 'package:itto/presentation/home/screens/home_screen.dart';
import 'package:itto/presentation/chat/screens/chat_list_screen.dart';
import 'package:itto/presentation/chat/screens/chat_room_screen.dart';
import 'package:itto/presentation/notification/screens/notification_screen.dart';
import 'package:itto/presentation/settings/screens/settings_screen.dart';
import 'package:itto/presentation/settings/screens/profile_edit_screen.dart';
import 'package:itto/presentation/settings/screens/profile_photo_screen.dart';
import 'package:itto/presentation/settings/screens/connection_range_screen.dart';
import 'package:itto/presentation/settings/screens/currency_screen.dart';
import 'package:itto/presentation/settings/screens/notification_settings_screen.dart';
import 'package:itto/presentation/settings/screens/subscription_screen.dart';
import 'package:itto/presentation/map/screens/map_screen.dart';
import 'package:itto/presentation/map/screens/excluded_area_screen.dart';
import 'package:itto/presentation/map/screens/encounter_location_screen.dart';
import 'package:itto/presentation/profile/screens/profile_detail_screen.dart';
import 'package:itto/presentation/auth/screens/signup/tutorial_screen.dart';
import 'package:itto/presentation/common/widgets/main_shell.dart';

GoRouter _createTestRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupFlowScreen()),
      GoRoute(path: '/verification-pending', builder: (context, state) => const VerificationPendingScreen()),
      GoRoute(path: '/verification-rejected', builder: (context, state) => const VerificationRejectedScreen()),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/chat', builder: (context, state) => const ChatListScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: rootKey,
        builder: (context, state) => ChatRoomScreen(
          chatId: state.pathParameters['id'] ?? '',
          userName: state.uri.queryParameters['name'] ?? '',
        ),
      ),
      GoRoute(path: '/profile/edit', parentNavigatorKey: rootKey, builder: (context, state) => const ProfileEditScreen()),
      GoRoute(path: '/profile/photo', parentNavigatorKey: rootKey, builder: (context, state) => const ProfilePhotoScreen()),
      GoRoute(
        path: '/profile/:userId',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
          return ProfileDetailScreen(userId: userId);
        },
      ),
      GoRoute(path: '/settings/range', parentNavigatorKey: rootKey, builder: (context, state) => const ConnectionRangeScreen()),
      GoRoute(path: '/settings/currency', parentNavigatorKey: rootKey, builder: (context, state) => const CurrencyScreen()),
      GoRoute(path: '/settings/subscription', parentNavigatorKey: rootKey, builder: (context, state) => const SubscriptionScreen()),
      GoRoute(path: '/settings/notifications', parentNavigatorKey: rootKey, builder: (context, state) => const NotificationSettingsScreen()),
      GoRoute(path: '/tutorial', parentNavigatorKey: rootKey, builder: (context, state) => const TutorialScreen()),
      GoRoute(path: '/map', parentNavigatorKey: rootKey, builder: (context, state) => const MapScreen()),
      GoRoute(path: '/map/excluded', parentNavigatorKey: rootKey, builder: (context, state) => const ExcludedAreaScreen()),
      GoRoute(
        path: '/encounter/:relationshipId',
        parentNavigatorKey: rootKey,
        builder: (context, state) {
          final relationshipId = int.tryParse(state.pathParameters['relationshipId'] ?? '') ?? 0;
          return EncounterLocationScreen(relationshipId: relationshipId);
        },
      ),
    ],
  );
}

class TestIttoApp extends StatelessWidget {
  const TestIttoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Itto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _createTestRouter(),
    );
  }
}
