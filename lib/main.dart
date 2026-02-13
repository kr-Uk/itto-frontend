import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'core/services/fcm_service.dart';
import 'core/services/background_location_handler.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/services/firebase_auth_service.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // FCM 초기화 (토큰 획득 및 메시지 핸들러 설정)
  await FcmService.instance.initialize();

  // 백그라운드 위치 추적 headless task 등록
  // (앱 종료 후에도 위치 이벤트 처리)
  bg.BackgroundGeolocation.registerHeadlessTask(
      backgroundGeolocationHeadlessTask);

  kakao.KakaoSdk.init(nativeAppKey: '3740d88d315908803690e901d0be9ea2');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient.getInstance(tokenStorage: tokenStorage);
  final firebaseAuthService = FirebaseAuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(apiClient),
            firebaseAuthService: firebaseAuthService,
            tokenStorage: tokenStorage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SignupProvider(
            signupService: SignupService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            profileService: ProfileService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RelationshipProvider(
            service: RelationshipService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(
            service: NotificationService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            service: SettingsService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            service: LocationService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ShopProvider(
            service: ShopService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BlockProvider(
            service: BlockService(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatService: ChatService(),
          ),
        ),
      ],
      child: const IttoApp(),
    ),
  );
}
