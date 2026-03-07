import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/network/api_client.dart';
import 'package:itto/core/storage/token_storage.dart';
import 'package:itto/data/auth/datasources/auth_remote_datasource.dart';
import 'package:itto/data/auth/datasources/oauth_service.dart' as data;
import 'package:itto/domain/auth/services/oauth_service.dart';
import 'package:itto/data/auth/datasources/signup_remote_datasource.dart';
import 'package:itto/data/auth/repositories/auth_repository_impl.dart';
import 'package:itto/data/auth/repositories/signup_repository_impl.dart';
import 'package:itto/data/block/datasources/block_remote_datasource.dart';
import 'package:itto/data/block/repositories/block_repository_impl.dart';
import 'package:itto/data/chat/datasources/chat_firestore_datasource.dart';
import 'package:itto/data/chat/repositories/chat_repository_impl.dart';
import 'package:itto/data/contact_hash/datasources/contact_hash_remote_datasource.dart';
import 'package:itto/data/contact_hash/repositories/contact_hash_repository_impl.dart';
import 'package:itto/data/location/datasources/location_remote_datasource.dart';
import 'package:itto/data/location/repositories/location_repository_impl.dart';
import 'package:itto/data/notification/datasources/notification_remote_datasource.dart';
import 'package:itto/data/notification/repositories/notification_repository_impl.dart';
import 'package:itto/data/profile/datasources/profile_remote_datasource.dart';
import 'package:itto/data/profile/repositories/profile_repository_impl.dart';
import 'package:itto/data/relationship/datasources/relationship_remote_datasource.dart';
import 'package:itto/data/relationship/repositories/relationship_repository_impl.dart';
import 'package:itto/data/settings/datasources/settings_remote_datasource.dart';
import 'package:itto/data/settings/repositories/settings_repository_impl.dart';
import 'package:itto/data/shop/datasources/shop_remote_datasource.dart';
import 'package:itto/data/shop/repositories/shop_repository_impl.dart';
import 'package:itto/data/system/datasources/system_remote_datasource.dart';
import 'package:itto/data/system/repositories/system_repository_impl.dart';
import 'package:itto/domain/auth/repositories/auth_repository.dart';
import 'package:itto/domain/auth/repositories/signup_repository.dart';
import 'package:itto/domain/block/repositories/block_repository.dart';
import 'package:itto/domain/chat/repositories/chat_repository.dart';
import 'package:itto/domain/contact_hash/repositories/contact_hash_repository.dart';
import 'package:itto/domain/contact_hash/usecases/hash_contacts_usecase.dart';
import 'package:itto/domain/contact_hash/usecases/sync_contact_hashes_usecase.dart';
import 'package:itto/domain/location/repositories/location_repository.dart';
import 'package:itto/domain/notification/repositories/notification_repository.dart';
import 'package:itto/domain/profile/repositories/profile_repository.dart';
import 'package:itto/domain/relationship/repositories/relationship_repository.dart';
import 'package:itto/domain/settings/repositories/settings_repository.dart';
import 'package:itto/domain/shop/repositories/shop_repository.dart';
import 'package:itto/domain/system/repositories/system_repository.dart';
import 'package:itto/presentation/auth/providers/auth_provider.dart';
import 'package:itto/presentation/auth/providers/signup_provider.dart';
import 'package:itto/presentation/block/providers/block_provider.dart';
import 'package:itto/presentation/chat/providers/chat_provider.dart';
import 'package:itto/presentation/contact_hash/providers/contact_hash_provider.dart';
import 'package:itto/presentation/location/providers/location_provider.dart';
import 'package:itto/presentation/notification/providers/notification_provider.dart';
import 'package:itto/presentation/profile/providers/profile_provider.dart';
import 'package:itto/presentation/relationship/providers/relationship_provider.dart';
import 'package:itto/presentation/settings/providers/settings_provider.dart';
import 'package:itto/presentation/shop/providers/shop_provider.dart';

// ─── Core ───

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient.getInstance(tokenStorage: tokenStorage);
});

final oauthServiceProvider = Provider<OAuthService>((ref) {
  return data.OAuthServiceImpl();
});

// ─── DataSources ───

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final signupRemoteDataSourceProvider = Provider<SignupRemoteDataSource>((ref) {
  return SignupRemoteDataSource(ref.watch(apiClientProvider));
});

final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.watch(apiClientProvider));
});

final relationshipRemoteDataSourceProvider =
    Provider<RelationshipRemoteDataSource>((ref) {
  return RelationshipRemoteDataSource(ref.watch(apiClientProvider));
});

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(ref.watch(apiClientProvider));
});

final settingsRemoteDataSourceProvider =
    Provider<SettingsRemoteDataSource>((ref) {
  return SettingsRemoteDataSource(ref.watch(apiClientProvider));
});

final locationRemoteDataSourceProvider =
    Provider<LocationRemoteDataSource>((ref) {
  return LocationRemoteDataSource(ref.watch(apiClientProvider));
});

final shopRemoteDataSourceProvider = Provider<ShopRemoteDataSource>((ref) {
  return ShopRemoteDataSource(ref.watch(apiClientProvider));
});

final blockRemoteDataSourceProvider = Provider<BlockRemoteDataSource>((ref) {
  return BlockRemoteDataSource(ref.watch(apiClientProvider));
});

final chatFirestoreDataSourceProvider =
    Provider<ChatFirestoreDataSource>((ref) {
  return ChatFirestoreDataSource();
});

final contactHashRemoteDataSourceProvider =
    Provider<ContactHashRemoteDataSource>((ref) {
  return ContactHashRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
});

final systemRemoteDataSourceProvider =
    Provider<SystemRemoteDataSource>((ref) {
  return SystemRemoteDataSource(ref.watch(apiClientProvider));
});

// ─── Repositories ───

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final signupRepositoryProvider = Provider<SignupRepository>((ref) {
  return SignupRepositoryImpl(
    remoteDataSource: ref.watch(signupRemoteDataSourceProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
  );
});

final relationshipRepositoryProvider = Provider<RelationshipRepository>((ref) {
  return RelationshipRepositoryImpl(
    remoteDataSource: ref.watch(relationshipRemoteDataSourceProvider),
  );
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.watch(notificationRemoteDataSourceProvider),
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(
    remoteDataSource: ref.watch(settingsRemoteDataSourceProvider),
  );
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    remoteDataSource: ref.watch(locationRemoteDataSourceProvider),
  );
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepositoryImpl(
    remoteDataSource: ref.watch(shopRemoteDataSourceProvider),
  );
});

final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  return BlockRepositoryImpl(
    remoteDataSource: ref.watch(blockRemoteDataSourceProvider),
  );
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(
    dataSource: ref.watch(chatFirestoreDataSourceProvider),
  );
});

final contactHashRepositoryProvider = Provider<ContactHashRepository>((ref) {
  return ContactHashRepositoryImpl(
    remoteDataSource: ref.watch(contactHashRemoteDataSourceProvider),
  );
});

final systemRepositoryProvider = Provider<SystemRepository>((ref) {
  return SystemRepositoryImpl(
    remoteDataSource: ref.watch(systemRemoteDataSourceProvider),
  );
});

// ─── UseCases ───

final hashContactsUseCaseProvider = Provider<HashContactsUseCase>((ref) {
  return HashContactsUseCase();
});

final syncContactHashesUseCaseProvider =
    Provider<SyncContactHashesUseCase>((ref) {
  return SyncContactHashesUseCase(
    repository: ref.watch(contactHashRepositoryProvider),
    hashContactsUseCase: ref.watch(hashContactsUseCaseProvider),
  );
});

// ─── Presentation Providers ───

final authChangeNotifierProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(
    authRepository: ref.watch(authRepositoryProvider),
    oauthService: ref.watch(oauthServiceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final signupChangeNotifierProvider =
    ChangeNotifierProvider<SignupProvider>((ref) {
  return SignupProvider(repository: ref.watch(signupRepositoryProvider));
});

final profileChangeNotifierProvider =
    ChangeNotifierProvider<ProfileProvider>((ref) {
  return ProfileProvider(repository: ref.watch(profileRepositoryProvider));
});

final relationshipChangeNotifierProvider =
    ChangeNotifierProvider<RelationshipProvider>((ref) {
  return RelationshipProvider(
    repository: ref.watch(relationshipRepositoryProvider),
  );
});

final notificationChangeNotifierProvider =
    ChangeNotifierProvider<NotificationProvider>((ref) {
  return NotificationProvider(
    repository: ref.watch(notificationRepositoryProvider),
  );
});

final settingsChangeNotifierProvider =
    ChangeNotifierProvider<SettingsProvider>((ref) {
  return SettingsProvider(repository: ref.watch(settingsRepositoryProvider));
});

final locationChangeNotifierProvider =
    ChangeNotifierProvider<LocationProvider>((ref) {
  return LocationProvider(repository: ref.watch(locationRepositoryProvider));
});

final shopChangeNotifierProvider = ChangeNotifierProvider<ShopProvider>((ref) {
  return ShopProvider(repository: ref.watch(shopRepositoryProvider));
});

final blockChangeNotifierProvider =
    ChangeNotifierProvider<BlockProvider>((ref) {
  return BlockProvider(repository: ref.watch(blockRepositoryProvider));
});

final chatChangeNotifierProvider = ChangeNotifierProvider<ChatProvider>((ref) {
  return ChatProvider(repository: ref.watch(chatRepositoryProvider));
});

final contactHashChangeNotifierProvider =
    ChangeNotifierProvider<ContactHashProvider>((ref) {
  return ContactHashProvider(
    repository: ref.watch(contactHashRepositoryProvider),
    syncContactHashesUseCase: ref.watch(syncContactHashesUseCaseProvider),
  );
});
