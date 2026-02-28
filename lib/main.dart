/// ==========================================================================
/// [앱 진입점 - main.dart]
///
/// Flutter 앱이 시작되는 첫 번째 파일입니다.
/// 스마트폰에서 앱 아이콘을 누르면 이 파일의 main() 함수가 가장 먼저 실행됩니다.
///
/// 여기서 하는 일:
/// - Firebase 초기화 (로그인, 푸시알림 등에 사용하는 구글 서비스)
/// - 카카오 SDK 초기화 (카카오 로그인을 위한 준비)
/// - FCM 초기화 (푸시 알림을 받기 위한 설정)
/// - 백그라운드 위치 추적 등록 (앱을 꺼도 위치를 추적하기 위한 설정)
/// - Provider 등록 (앱 전체에서 데이터를 공유하기 위한 상태관리 설정)
///
/// [Provider 패턴이란?]
/// 앱의 여러 화면에서 같은 데이터(예: 로그인 상태, 사용자 정보)를
/// 공유하기 위한 방법입니다. 마치 공용 게시판처럼, 한 곳에서 데이터를
/// 바꾸면 그 데이터를 보고 있는 모든 화면이 자동으로 업데이트됩니다.
/// ==========================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/services/fcm_service.dart';
import 'core/services/background_location_handler.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/services/oauth_service.dart';
import 'features/auth/services/identity_service.dart';
import 'features/auth/services/signup_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/providers/signup_provider.dart';
import 'features/profile/services/profile_service.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/relationship/services/relationship_service.dart';
import 'features/relationship/providers/relationship_provider.dart';
import 'features/notification/services/notification_service.dart';
import 'features/notification/providers/notification_provider.dart';
import 'features/settings/services/settings_service.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/location/services/location_service.dart';
import 'features/location/providers/location_provider.dart';
import 'features/shop/services/shop_service.dart';
import 'features/shop/providers/shop_provider.dart';
import 'features/block/services/block_service.dart';
import 'features/block/providers/block_provider.dart';
import 'features/chat/services/chat_service.dart';
import 'features/chat/providers/chat_provider.dart';
import 'app.dart';

/// 앱의 시작점 - 이 함수가 가장 먼저 실행됩니다
/// [async] 키워드: 이 함수 안에서 시간이 걸리는 작업(서버 통신, 파일 읽기 등)을
/// 기다렸다가 다음 줄로 넘어갈 수 있게 해줍니다.
void main() async {
  /// Flutter 엔진 초기화 - Flutter가 화면을 그리기 전에 필요한 준비를 합니다
  WidgetsFlutterBinding.ensureInitialized();

  /// .env 파일에서 환경변수(비밀키, 서버 주소 등)를 불러옵니다
  /// (.env 파일은 비밀번호 같은 민감한 정보를 코드와 분리하여 저장하는 파일)
  await dotenv.load(fileName: '.env');

  /// 앱이 종료된 상태에서도 위치 추적이 동작하도록, 서버 주소를 기기 저장소에 미리 저장합니다
  /// (SharedPreferences: 앱 내부에 간단한 데이터를 저장하는 저장소, 메모장처럼 사용)
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('api_base_url', dotenv.env['API_BASE_URL'] ?? 'https://api.hguitto.site/api/v1');

  /// Firebase 초기화 - 구글에서 제공하는 로그인, 푸시알림, 분석 등의 서비스를 사용하기 위한 준비
  await Firebase.initializeApp();

  /// 네이버 지도 SDK 초기화 - 지도 화면을 표시하기 위한 준비
  await FlutterNaverMap().init(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID'] ?? '',
  );

  /// FCM(Firebase Cloud Messaging) 초기화 - 서버에서 보내는 푸시 알림을 받기 위한 설정
  await FcmService.instance.initialize();

  /// 백그라운드 위치 추적 등록 - 앱을 완전히 종료해도 위치 변화를 감지하여 서버에 전송합니다
  /// (headless task: 앱 화면이 없어도 뒤에서 돌아가는 작업)
  bg.BackgroundGeolocation.registerHeadlessTask(
      backgroundGeolocationHeadlessTask);

  /// 카카오 SDK 초기화 - 카카오 로그인 기능을 사용하기 위한 준비
  kakao.KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
  );

  /// 상단 상태바(시간, 배터리 표시 영역) 스타일 설정 - 투명 배경, 흰색 아이콘
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  /// 핵심 서비스 객체들을 생성합니다
  final tokenStorage = TokenStorage(); // 로그인 토큰(출입증)을 저장/관리하는 객체
  final apiClient = ApiClient.getInstance(tokenStorage: tokenStorage); // 서버와 통신하는 HTTP 클라이언트
  final oAuthService = OAuthService(); // OAuth 직접 소셜 로그인 처리 객체

  /// runApp: Flutter 앱을 실제로 화면에 띄우는 함수
  ///
  /// [MultiProvider]: 여러 개의 Provider를 한꺼번에 등록합니다.
  /// 각 Provider는 특정 기능의 데이터를 관리합니다.
  /// 이렇게 등록하면 앱의 어느 화면에서든 해당 데이터에 접근할 수 있습니다.
  ///
  /// [ChangeNotifierProvider]: 데이터가 변경되면 자동으로 화면을 다시 그려주는 Provider입니다.
  /// 예를 들어, 로그인 상태가 바뀌면 로그인 버튼이 자동으로 사라지는 식입니다.
  runApp(
    MultiProvider(
      providers: [
        /// 인증(로그인/로그아웃) 상태를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(apiClient),
            oAuthService: oAuthService,
            tokenStorage: tokenStorage,
          ),
        ),
        /// 본인인증 서비스 Provider
        Provider<IdentityService>(
          create: (_) => IdentityService(apiClient),
        ),
        /// 회원가입 과정 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => SignupProvider(
            signupService: SignupService(apiClient),
          ),
        ),
        /// 사용자 프로필(닉네임, 사진 등) 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            profileService: ProfileService(apiClient),
          ),
        ),
        /// 인연(매칭된 사람들과의 관계) 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => RelationshipProvider(
            service: RelationshipService(apiClient),
          ),
        ),
        /// 알림 목록 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            service: NotificationService(apiClient),
          ),
        ),
        /// 앱 설정(알림 설정, 연결 범위 등) 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            service: SettingsService(apiClient),
          ),
        ),
        /// 위치 관련 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            service: LocationService(apiClient),
          ),
        ),
        /// 상점(아이템 구매 등) 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => ShopProvider(
            service: ShopService(apiClient),
          ),
        ),
        /// 차단 기능 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => BlockProvider(
            service: BlockService(apiClient),
          ),
        ),
        /// 채팅 기능 데이터를 관리하는 Provider
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatService: ChatService(),
          ),
        ),
      ],
      child: const IttoApp(), // 실제 앱 화면을 시작하는 위젯
    ),
  );
}
