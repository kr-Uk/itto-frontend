// 화면 이동(라우팅) 설정 — GoRouter 기반 앱 라우트 정의.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:itto/presentation/map/screens/map_screen.dart';
import 'package:itto/presentation/map/screens/excluded_area_screen.dart';
import 'package:itto/presentation/map/screens/encounter_location_screen.dart';
import 'package:itto/presentation/profile/screens/profile_detail_screen.dart';
import 'package:itto/presentation/settings/screens/subscription_screen.dart';
import 'package:itto/presentation/auth/screens/signup/tutorial_screen.dart';
import 'package:itto/presentation/common/widgets/main_shell.dart';

/// 전체 화면 이동용 키 (하단 탭바 없이 전체 화면으로 이동할 때 사용)
/// 인앱 알림 배너 표시 등에서도 사용됩니다.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// ShellRoute 내부 이동용 키 (하단 탭바를 유지하면서 화면을 전환할 때 사용)
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// 앱의 전체 라우팅(화면 이동) 규칙을 정의합니다
/// initialLocation: 앱 시작 시 처음 보여줄 화면 ('/splash' = 스플래시 화면)
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    /// ── 독립 화면들 (하단 탭바 없음) ──
    /// 스플래시 화면: 앱 시작 시 로고가 나오는 화면
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    /// 로그인 화면
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    /// 회원가입 화면
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupFlowScreen(),
    ),

    /// 얼굴 인증 승인 대기 화면
    GoRoute(
      path: '/verification-pending',
      builder: (context, state) => const VerificationPendingScreen(),
    ),

    /// 얼굴 인증 거부/재인증 화면
    GoRoute(
      path: '/verification-rejected',
      builder: (context, state) => const VerificationRejectedScreen(),
    ),

    /// ── ShellRoute: 하단 탭바(홈/채팅/알림/설정)가 있는 메인 영역 ──
    /// 이 안의 화면들은 MainShell(하단 네비게이션 바)을 공유합니다
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(), // 홈(메인) 화면
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ChatListScreen(), // 채팅 목록 화면
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(), // 알림 화면
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(), // 설정 화면
        ),
      ],
    ),

    /// ── 전체 화면 이동 (하단 탭바 숨김) ──
    /// parentNavigatorKey: rootNavigatorKey → 하단 탭바 위에 전체 화면으로 표시

    /// 채팅방 상세 화면 (':id'는 채팅방 고유번호로 대체됨, 예: /chat/abc123)
    GoRoute(
      path: '/chat/:id',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => ChatRoomScreen(
        chatId: state.pathParameters['id'] ?? '',
        userName: state.uri.queryParameters['name'] ?? '',
      ),
    ),

    /// 프로필 수정 화면
    GoRoute(
      path: '/profile/edit',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfileEditScreen(),
    ),

    /// 프로필 사진 관리 화면
    GoRoute(
      path: '/profile/photo',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ProfilePhotoScreen(),
    ),

    /// 다른 사용자의 프로필 상세 화면 (':userId'는 사용자 번호로 대체됨)
    GoRoute(
      path: '/profile/:userId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final userId = int.tryParse(state.pathParameters['userId'] ?? '') ?? 0;
        return ProfileDetailScreen(userId: userId);
      },
    ),

    /// 연결 범위 설정 화면
    GoRoute(
      path: '/settings/range',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ConnectionRangeScreen(),
    ),

    /// 화폐(인앱 결제) 관리 화면
    GoRoute(
      path: '/settings/currency',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CurrencyScreen(),
    ),

    /// 구독 관리 화면
    GoRoute(
      path: '/settings/subscription',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SubscriptionScreen(),
    ),

    /// 알림 설정 화면
    GoRoute(
      path: '/settings/notifications',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),

    /// 튜토리얼 화면
    GoRoute(
      path: '/tutorial',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final fromSignup = state.extra as bool? ?? false;
        return TutorialScreen(fromSignup: fromSignup);
      },
    ),

    /// 지도 화면
    GoRoute(
      path: '/map',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MapScreen(),
    ),

    /// 제외 구역 설정 화면 (이 지역에서는 매칭하지 않겠다는 설정)
    GoRoute(
      path: '/map/excluded',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ExcludedAreaScreen(),
    ),

    /// 만남 위치 확인 화면
    GoRoute(
      path: '/encounter/:relationshipId',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id =
            int.tryParse(state.pathParameters['relationshipId'] ?? '') ?? 0;
        return EncounterLocationScreen(relationshipId: id);
      },
    ),
  ],
);
