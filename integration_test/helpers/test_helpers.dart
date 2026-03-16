/// Integration Test 공통 헬퍼.
/// Mock Repository/Service/Provider와 테스트 유틸리티를 제공한다.
/// 모든 외부 의존성(Firebase, 소셜 로그인, 위치 서비스, Firestore)은
/// Mock으로 대체하여 네트워크 없이 테스트할 수 있게 한다.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:itto/core/di/providers.dart';
import 'package:itto/core/storage/token_storage.dart';
import 'package:itto/domain/auth/entities/login_result.dart';
import 'package:itto/domain/auth/repositories/auth_repository.dart';
import 'package:itto/domain/auth/repositories/signup_repository.dart';
import 'package:itto/domain/auth/services/oauth_service.dart';
import 'package:itto/domain/block/entities/report_request.dart';
import 'package:itto/domain/block/repositories/block_repository.dart';
import 'package:itto/domain/chat/entities/chat_message.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';
import 'package:itto/domain/chat/repositories/chat_repository.dart';
import 'package:itto/domain/common/entities/hobby.dart';
import 'package:itto/domain/common/entities/page_response.dart';
import 'package:itto/domain/common/entities/photo.dart';
import 'package:itto/domain/contact_hash/repositories/contact_hash_repository.dart';
import 'package:itto/domain/location/entities/location_toggle_result.dart';
import 'package:itto/domain/location/repositories/location_repository.dart';
import 'package:itto/domain/notification/entities/notification_item.dart';
import 'package:itto/domain/notification/repositories/notification_repository.dart';
import 'package:itto/domain/profile/entities/my_profile.dart';
import 'package:itto/domain/profile/repositories/profile_repository.dart';
import 'package:itto/domain/relationship/entities/relationship.dart';
import 'package:itto/domain/relationship/repositories/relationship_repository.dart';
import 'package:itto/domain/settings/entities/matching_settings.dart';
import 'package:itto/domain/settings/entities/notification_settings.dart';
import 'package:itto/domain/settings/repositories/settings_repository.dart';
import 'package:itto/domain/shop/entities/knot_balance.dart';
import 'package:itto/domain/shop/entities/subscription.dart';
import 'package:itto/domain/shop/repositories/shop_repository.dart';
import 'package:itto/domain/system/entities/nickname_validation.dart';
import 'package:itto/domain/system/entities/version_info.dart';
import 'package:itto/domain/system/repositories/system_repository.dart';

// ─── Mock Classes ───

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSignupRepository extends Mock implements SignupRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockRelationshipRepository extends Mock
    implements RelationshipRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockShopRepository extends Mock implements ShopRepository {}

class MockBlockRepository extends Mock implements BlockRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockContactHashRepository extends Mock
    implements ContactHashRepository {}

class MockSystemRepository extends Mock implements SystemRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockOAuthService extends Mock implements OAuthService {}

// ─── Fallback Values ───

class FakeReportRequest extends Fake implements ReportRequest {}

void registerFallbackValues() {
  registerFallbackValue(FakeReportRequest());
  registerFallbackValue(const MatchingSettings(ageRangeMin: 20, ageRangeMax: 40));
  registerFallbackValue(const NotificationSettings(
    chatNotification: true,
    relationshipNotification: true,
    statsNotification: true,
    marketingNotification: false,
  ));
}

// ─── Test Data ───

const testMyProfile = MyProfile(
  userId: 1,
  nickname: '테스트유저',
  gender: 'MALE',
  birthDate: '1995-01-15',
  age: 31,
  hobbies: [Hobby(id: 1, name: '운동'), Hobby(id: 2, name: '독서')],
  introduction: '안녕하세요, 테스트 유저입니다.',
  photos: [Photo(id: 1, url: 'https://example.com/photo.jpg', isRepresentative: true)],
  verificationStatus: 'APPROVED',
  knots: 100,
  isPremium: false,
  createdAt: '2026-01-01T00:00:00',
);

const testLoginResult = LoginResult(
  accessToken: 'test_access_token',
  refreshToken: 'test_refresh_token',
  isNewUser: false,
  verificationStatus: 'APPROVED',
);

const testNewUserLoginResult = LoginResult(
  accessToken: 'test_access_token',
  refreshToken: 'test_refresh_token',
  isNewUser: true,
  verificationStatus: 'NONE',
);

final testRelationships = <String, List<Relationship>>{
  'INYEON': [
    const Relationship(
      relationshipId: 1,
      otherUser: RelationshipOtherUser(userId: 2, nickname: '인연상대'),
      status: 'INYEON',
      encounterCount: 5,
      createdAt: '2026-02-01T00:00:00',
      chatRoomId: 'chat_room_1',
      destinyBadge: true,
    ),
  ],
  'PILYEON': [
    const Relationship(
      relationshipId: 2,
      otherUser: RelationshipOtherUser(userId: 3, nickname: '필연상대'),
      status: 'PILYEON',
      encounterCount: 3,
      createdAt: '2026-02-10T00:00:00',
      destinyBadge: true,
    ),
  ],
  'UYEON': [
    const Relationship(
      relationshipId: 3,
      otherUser: RelationshipOtherUser(userId: 4, nickname: '우연상대'),
      status: 'UYEON',
      encounterCount: 1,
      createdAt: '2026-03-01T00:00:00',
    ),
  ],
  'PAST': [
    const Relationship(
      relationshipId: 4,
      otherUser: RelationshipOtherUser(userId: 5, nickname: '지난인연'),
      status: 'PAST_INYEON',
      encounterCount: 7,
      createdAt: '2026-01-15T00:00:00',
    ),
  ],
  'PENDING': [],
};

final testChatRooms = [
  ChatRoom(
    id: 'chat_room_1',
    participantIds: const [1, 2],
    participantNames: const {1: '테스트유저', 2: '인연상대'},
    lastMessage: '안녕하세요!',
    lastMessageAt: DateTime(2026, 3, 15, 14, 30),
    unreadCount: 2,
  ),
];

final testMessages = [
  ChatMessage(
    id: 'msg_1',
    senderId: 2,
    text: '안녕하세요!',
    createdAt: DateTime(2026, 3, 15, 14, 28),
    readBy: const [1, 2],
  ),
  ChatMessage(
    id: 'msg_2',
    senderId: 1,
    text: '반가워요!',
    createdAt: DateTime(2026, 3, 15, 14, 30),
    readBy: const [1],
  ),
];

const testKnotBalance = KnotBalance(
  knots: 100,
  freeConvertRemaining: 1,
  freeRequestRemaining: 1,
  freeRestoreRemaining: 1,
);

const testHobbies = [
  Hobby(id: 1, name: '운동', category: '스포츠'),
  Hobby(id: 2, name: '독서', category: '문화'),
  Hobby(id: 3, name: '영화 감상', category: '문화'),
  Hobby(id: 4, name: '요리', category: '생활'),
  Hobby(id: 5, name: '여행', category: '여가'),
];

// ─── Mock Setup ───

/// 기본 Mock Repository 세팅.
/// 모든 Repository를 Mock으로 생성하고, 기본 동작(성공 응답)을 등록한다.
class MockSetup {
  final mockAuthRepo = MockAuthRepository();
  final mockSignupRepo = MockSignupRepository();
  final mockProfileRepo = MockProfileRepository();
  final mockRelationshipRepo = MockRelationshipRepository();
  final mockNotificationRepo = MockNotificationRepository();
  final mockSettingsRepo = MockSettingsRepository();
  final mockLocationRepo = MockLocationRepository();
  final mockShopRepo = MockShopRepository();
  final mockBlockRepo = MockBlockRepository();
  final mockChatRepo = MockChatRepository();
  final mockContactHashRepo = MockContactHashRepository();
  final mockSystemRepo = MockSystemRepository();
  final mockTokenStorage = MockTokenStorage();
  final mockOAuthService = MockOAuthService();

  MockSetup() {
    _setupAuthDefaults();
    _setupProfileDefaults();
    _setupRelationshipDefaults();
    _setupNotificationDefaults();
    _setupSettingsDefaults();
    _setupShopDefaults();
    _setupChatDefaults();
    _setupBlockDefaults();
    _setupSignupDefaults();
    _setupSystemDefaults();
    _setupLocationDefaults();
    _setupTokenStorageDefaults();
    _setupOAuthDefaults();
  }

  void _setupTokenStorageDefaults() {
    when(() => mockTokenStorage.hasTokens()).thenAnswer((_) async => true);
    when(() => mockTokenStorage.getAccessToken())
        .thenAnswer((_) async => 'test_access_token');
    when(() => mockTokenStorage.getRefreshToken())
        .thenAnswer((_) async => 'test_refresh_token');
    when(() => mockTokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => mockTokenStorage.clearTokens()).thenAnswer((_) async {});
  }

  void _setupOAuthDefaults() {
    when(() => mockOAuthService.signInWithGoogle())
        .thenAnswer((_) async => const OAuthResult(token: 'google_token', provider: 'GOOGLE'));
    when(() => mockOAuthService.signInWithKakao())
        .thenAnswer((_) async => const OAuthResult(token: 'kakao_token', provider: 'KAKAO'));
    when(() => mockOAuthService.signInWithApple())
        .thenAnswer((_) async => const OAuthResult(token: 'apple_token', provider: 'APPLE'));
    when(() => mockOAuthService.signOut()).thenAnswer((_) async {});
  }

  void _setupAuthDefaults() {
    when(() => mockAuthRepo.login(
          oauthToken: any(named: 'oauthToken'),
          provider: any(named: 'provider'),
          fcmToken: any(named: 'fcmToken'),
        )).thenAnswer((_) async => testLoginResult);
    when(() => mockAuthRepo.logout()).thenAnswer((_) async {});
    when(() => mockAuthRepo.withdraw(reason: any(named: 'reason')))
        .thenAnswer((_) async {});
  }

  void _setupProfileDefaults() {
    when(() => mockProfileRepo.getMyProfile())
        .thenAnswer((_) async => testMyProfile);
    when(() => mockProfileRepo.getHobbies())
        .thenAnswer((_) async => testHobbies);
    when(() => mockProfileRepo.updateProfile(
          nickname: any(named: 'nickname'),
          hobbyIds: any(named: 'hobbyIds'),
          introduction: any(named: 'introduction'),
        )).thenAnswer((_) async {});
  }

  void _setupRelationshipDefaults() {
    for (final status in ['INYEON', 'PILYEON', 'UYEON', 'PAST', 'PENDING']) {
      when(() => mockRelationshipRepo.getList(
            status: status,
            page: any(named: 'page'),
          )).thenAnswer((_) async => PageResponse<Relationship>(
            content: testRelationships[status] ?? [],
            page: 0,
            size: 20,
            totalElements: (testRelationships[status] ?? []).length,
            totalPages: 1,
          ));
    }
  }

  void _setupNotificationDefaults() {
    when(() => mockNotificationRepo.getList(
          page: any(named: 'page'),
          size: any(named: 'size'),
        )).thenAnswer((_) async => const PageResponse<NotificationItem>(
          content: [],
          page: 0,
          size: 20,
          totalElements: 0,
          totalPages: 0,
        ));
    when(() => mockNotificationRepo.updateFcmToken(
          fcmToken: any(named: 'fcmToken'),
          deviceId: any(named: 'deviceId'),
        )).thenAnswer((_) async {});
  }

  void _setupSettingsDefaults() {
    when(() => mockSettingsRepo.getMatchingSettings())
        .thenAnswer((_) async => const MatchingSettings(
              ageRangeMin: 20,
              ageRangeMax: 40,
            ));
    when(() => mockSettingsRepo.updateMatchingSettings(any()))
        .thenAnswer((_) async {});
    when(() => mockSettingsRepo.getNotificationSettings())
        .thenAnswer((_) async => const NotificationSettings(
              chatNotification: true,
              relationshipNotification: true,
              statsNotification: true,
              marketingNotification: false,
            ));
    when(() => mockSettingsRepo.updateNotificationSettings(any()))
        .thenAnswer((_) async {});
  }

  void _setupShopDefaults() {
    when(() => mockShopRepo.getKnots())
        .thenAnswer((_) async => testKnotBalance);
    when(() => mockShopRepo.getPackages()).thenAnswer((_) async => []);
    when(() => mockShopRepo.getSubscription())
        .thenAnswer((_) async => const SubscriptionInfo(isPremium: false));
  }

  void _setupChatDefaults() {
    when(() => mockChatRepo.getChatRoomsStream(any(), any()))
        .thenAnswer((_) => Stream.value(testChatRooms));
    when(() => mockChatRepo.getMessagesStream(any()))
        .thenAnswer((_) => Stream.value(testMessages));
    when(() => mockChatRepo.sendMessage(
          chatRoomId: any(named: 'chatRoomId'),
          senderId: any(named: 'senderId'),
          text: any(named: 'text'),
          type: any(named: 'type'),
        )).thenAnswer((_) async {});
    when(() => mockChatRepo.markAsRead(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockChatRepo.ensureChatRoomExists(
          chatRoomId: any(named: 'chatRoomId'),
          participantIds: any(named: 'participantIds'),
        )).thenAnswer((_) async {});
  }

  void _setupBlockDefaults() {
    when(() => mockBlockRepo.listBlocks()).thenAnswer((_) async => []);
    when(() => mockBlockRepo.blockUser(any())).thenAnswer((_) async {});
    when(() => mockBlockRepo.report(any())).thenAnswer((_) async {});
  }

  void _setupSignupDefaults() {
    when(() => mockSignupRepo.getHobbies())
        .thenAnswer((_) async => testHobbies);
    when(() => mockSignupRepo.saveTerms(
          serviceTerms: any(named: 'serviceTerms'),
          privacyPolicy: any(named: 'privacyPolicy'),
          locationTerms: any(named: 'locationTerms'),
          marketingConsent: any(named: 'marketingConsent'),
        )).thenAnswer((_) async {});
    when(() => mockSignupRepo.saveProfile(
          nickname: any(named: 'nickname'),
          gender: any(named: 'gender'),
          birthDate: any(named: 'birthDate'),
          hobbyIds: any(named: 'hobbyIds'),
          introduction: any(named: 'introduction'),
        )).thenAnswer((_) async {});
    when(() => mockSignupRepo.uploadPhotos(
          filePaths: any(named: 'filePaths'),
          representativeIndex: any(named: 'representativeIndex'),
        )).thenAnswer((_) async => [const Photo(id: 1, url: 'https://example.com/photo.jpg', isRepresentative: true)]);
    when(() => mockSignupRepo.complete()).thenAnswer((_) async {});
  }

  void _setupSystemDefaults() {
    when(() => mockSystemRepo.checkVersion())
        .thenAnswer((_) async => const VersionInfo(
              minVersion: '1.0.0',
              latestVersion: '1.0.0',
              forceUpdate: false,
              updateUrl: '',
            ));
    when(() => mockSystemRepo.validateNickname(any()))
        .thenAnswer((_) async => const NicknameValidation(
              valid: true,
              message: '사용 가능한 닉네임입니다',
            ));
  }

  void _setupLocationDefaults() {
    when(() => mockLocationRepo.toggle(any()))
        .thenAnswer((_) async => const LocationToggleResult(enabled: true, message: ''));
    when(() => mockLocationRepo.listExcluded())
        .thenAnswer((_) async => []);
  }

  /// 모든 Mock을 Riverpod Provider overrides로 변환한다.
  /// IttoApp을 ProviderScope로 감쌀 때 이 overrides를 사용한다.
  List<Override> get overrides => [
        // Core
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
        oauthServiceProvider.overrideWithValue(mockOAuthService),

        // Repositories
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        signupRepositoryProvider.overrideWithValue(mockSignupRepo),
        profileRepositoryProvider.overrideWithValue(mockProfileRepo),
        relationshipRepositoryProvider.overrideWithValue(mockRelationshipRepo),
        notificationRepositoryProvider.overrideWithValue(mockNotificationRepo),
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
        locationRepositoryProvider.overrideWithValue(mockLocationRepo),
        shopRepositoryProvider.overrideWithValue(mockShopRepo),
        blockRepositoryProvider.overrideWithValue(mockBlockRepo),
        chatRepositoryProvider.overrideWithValue(mockChatRepo),
        contactHashRepositoryProvider.overrideWithValue(mockContactHashRepo),
        systemRepositoryProvider.overrideWithValue(mockSystemRepo),
      ];
}

/// 로그인 상태로 시작하는 테스트 앱을 pumpWidget으로 띄운다.
/// splash -> login 자동 전환 대신, 직접 /home으로 이동하는 설정.
Future<MockSetup> pumpAppLoggedIn(WidgetTester tester) async {
  final mocks = MockSetup();
  // 토큰 있음 → 로그인 상태
  when(() => mocks.mockTokenStorage.hasTokens()).thenAnswer((_) async => true);

  await tester.pumpWidget(
    ProviderScope(
      overrides: mocks.overrides,
      child: const MaterialApp(home: SizedBox()), // placeholder
    ),
  );
  return mocks;
}

/// 비로그인 상태로 시작하는 테스트 앱을 pumpWidget으로 띄운다.
Future<MockSetup> pumpAppLoggedOut(WidgetTester tester) async {
  final mocks = MockSetup();
  when(() => mocks.mockTokenStorage.hasTokens()).thenAnswer((_) async => false);

  await tester.pumpWidget(
    ProviderScope(
      overrides: mocks.overrides,
      child: const MaterialApp(home: SizedBox()),
    ),
  );
  return mocks;
}
