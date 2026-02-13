import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup/signup_flow_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_room_screen.dart';
import '../../features/notification/screens/notification_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/profile_edit_screen.dart';
import '../../features/settings/screens/profile_photo_screen.dart';
import '../../features/settings/screens/connection_range_screen.dart';
import '../../features/settings/screens/currency_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/map/screens/excluded_area_screen.dart';
import '../../features/profile/screens/profile_detail_screen.dart';
import '../../shared/widgets/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupFlowScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatListScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/chat/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ChatRoomScreen(
        chatId: state.pathParameters['id'] ?? '',
        userName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/profile/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/profile/photo',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfilePhotoScreen(),
    ),
    GoRoute(
      path: '/profile/:userId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
        return ProfileDetailScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/settings/range',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ConnectionRangeScreen(),
    ),
    GoRoute(
      path: '/settings/currency',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CurrencyScreen(),
    ),
    GoRoute(
      path: '/map',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/map/excluded',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExcludedAreaScreen(),
    ),
  ],
);
