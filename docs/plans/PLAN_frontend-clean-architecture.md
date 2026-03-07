# Frontend Clean Architecture Refactoring Plan

## 1. Current State Analysis

### 1.1 Current Structure

```
lib/
├── app.dart
├── main.dart
├── core/
│   ├── config/app_config.dart
│   ├── network/
│   │   ├── api_client.dart          # Singleton HTTP client (Dio)
│   │   ├── api_exception.dart
│   │   └── auth_interceptor.dart
│   ├── router/app_router.dart
│   ├── services/
│   │   ├── background_location_handler.dart
│   │   └── fcm_service.dart
│   ├── storage/token_storage.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── features/
│   ├── auth/          models/ providers/ screens/ services/
│   ├── block/         models/ providers/ services/
│   ├── chat/          models/ providers/ screens/ services/
│   ├── contact_hash/  data/ domain/ presentation/  ← Clean Architecture 적용됨
│   ├── home/          screens/
│   ├── location/      models/ providers/ services/
│   ├── map/           screens/
│   ├── notification/  models/ providers/ screens/ services/
│   ├── profile/       models/ providers/ services/
│   ├── relationship/  models/ providers/ screens/ services/
│   ├── settings/      models/ providers/ screens/ services/
│   ├── shop/          models/ providers/ screens/ services/
│   ├── splash/        screens/
│   └── system/        models/ services/
└── shared/
    ├── models/        api_response.dart, page_response.dart
    ├── utils/         snackbar_utils.dart
    └── widgets/       itto_app_bar.dart, itto_dialog.dart, main_shell.dart, purple_button.dart
```

### 1.2 Key Issues

| Issue | Description |
|-------|-------------|
| **Domain layer 부재** | 13개 feature 중 `contact_hash`만 domain layer가 있음. 나머지는 Model이 fromJson/toJson과 비즈니스 엔티티 역할을 동시에 수행 |
| **Service = DataSource** | Service 클래스들이 API 호출 + 데이터 변환을 모두 담당. Repository 추상화 없음 |
| **Provider = Business Logic** | Provider(ChangeNotifier)가 비즈니스 로직 + 상태 관리 + 에러 처리 모두 담당 |
| **DI 없음** | `main.dart`에서 수동으로 Service를 생성하여 Provider에 주입. 추상 인터페이스 없이 구현체 직접 의존 |
| **Model 중복** | `HobbyItem`, `PhotoItem`이 `signup_models.dart`에 정의되어 `profile`에서도 import. 공통 entity 분리 필요 |
| **cross-feature 의존** | `profile/models`가 `auth/models`를 import, `system/services`가 `profile/models`를 import |

### 1.3 Reference Pattern: `contact_hash`

Clean Architecture가 이미 적용된 `contact_hash` feature를 참고 패턴으로 사용:

```
contact_hash/
├── domain/
│   ├── entities/contact_hash.dart           # Pure Dart entity (no JSON)
│   ├── repositories/contact_hash_repository.dart  # Abstract interface
│   └── usecases/
│       ├── hash_contacts_usecase.dart
│       ├── phone_number_normalizer.dart
│       └── sync_contact_hashes_usecase.dart
├── data/
│   ├── datasources/contact_hash_remote_datasource.dart
│   ├── models/contact_hash_model.dart       # DTO with fromJson/toJson/toEntity
│   └── repositories/contact_hash_repository_impl.dart
└── presentation/
    ├── providers/contact_hash_provider.dart
    └── widgets/contact_block_section.dart
```

**Key conventions from this pattern:**
- Entity: 순수 Dart 클래스, JSON 직렬화 없음
- Model: `fromJson()`, `toJson()`, `toEntity()` 메서드 포함
- Repository: domain에 abstract, data에 impl
- UseCase: 하나의 public `execute()` 메서드
- Provider: UseCase/Repository를 통해서만 데이터 접근

---

## 2. Target Structure

```
lib/
├── core/
│   ├── errors/
│   │   ├── failures.dart            # Failure sealed class
│   │   └── exceptions.dart          # Custom exceptions (기존 api_exception.dart 이동)
│   ├── network/
│   │   ├── api_client.dart
│   │   └── auth_interceptor.dart
│   ├── config/app_config.dart
│   ├── router/app_router.dart
│   ├── services/
│   │   ├── background_location_handler.dart
│   │   └── fcm_service.dart
│   ├── storage/token_storage.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── constants/app_constants.dart
│   └── utils/                       # 기존 shared/utils 이동
│       └── snackbar_utils.dart
├── features/
│   └── <feature>/
│       ├── domain/
│       │   ├── entities/            # Pure Dart entities
│       │   ├── repositories/        # Abstract repository interfaces
│       │   └── usecases/            # Use cases (1 public method each)
│       ├── data/
│       │   ├── datasources/         # Remote/Local data sources
│       │   ├── models/              # DTOs (fromJson/toJson/toEntity)
│       │   └── repositories/        # Repository implementations
│       └── presentation/
│           ├── providers/           # ChangeNotifier (state only)
│           ├── screens/             # Pages
│           └── widgets/             # Feature-specific widgets
├── shared/
│   ├── models/                      # 공통 DTO (PageResponse, ApiResponse)
│   └── widgets/                     # 공통 위젯
├── app.dart
└── main.dart
```

---

## 3. Feature-by-Feature Mapping

### 3.1 auth

**Current:**
- `models/auth_models.dart` → LoginRequest, LoginResponse, TokenResponse
- `models/signup_models.dart` → SignupTermsRequest, SignupProfileRequest, PhotoUploadResponse, PhotoItem
- `services/auth_service.dart` → login, refresh, logout, withdraw
- `services/signup_service.dart` → getHobbies, saveTerms, saveProfile, uploadPhotos, complete
- `services/oauth_service.dart` → kakaoLogin, googleLogin, appleLogin
- `services/identity_service.dart` → identity verification
- `providers/auth_provider.dart` → login flow, token management, logout
- `providers/signup_provider.dart` → 8-step signup state

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `user.dart` | User (id, nickname, verificationStatus) |
| domain/entities | `auth_token.dart` | AuthToken (accessToken, refreshToken) |
| domain/repositories | `auth_repository.dart` | login, refresh, logout, withdraw |
| domain/repositories | `signup_repository.dart` | saveTerms, saveProfile, uploadPhotos, complete |
| domain/usecases | `login_usecase.dart` | OAuth login + token storage |
| domain/usecases | `logout_usecase.dart` | logout + token clear |
| domain/usecases | `complete_signup_usecase.dart` | signup completion flow |
| data/models | `login_request_model.dart` | LoginRequest DTO |
| data/models | `login_response_model.dart` | LoginResponse DTO + toEntity |
| data/models | `signup_request_models.dart` | SignupTermsRequest, SignupProfileRequest DTOs |
| data/datasources | `auth_remote_datasource.dart` | API calls (현재 auth_service) |
| data/datasources | `signup_remote_datasource.dart` | API calls (현재 signup_service) |
| data/repositories | `auth_repository_impl.dart` | implements AuthRepository |
| data/repositories | `signup_repository_impl.dart` | implements SignupRepository |
| presentation/providers | `auth_provider.dart` | login state + UseCase 호출 |
| presentation/providers | `signup_provider.dart` | signup flow state |
| presentation/screens | (기존 screens/ 이동) | |

**Note:** `OAuthService`는 platform-specific이므로 `data/datasources/oauth_datasource.dart`로 이동. `HobbyItem`, `PhotoItem`은 shared entity로 분리.

### 3.2 profile

**Current:**
- `models/profile_models.dart` → MyProfile, HobbyItem, OtherProfile, OtherProfilePhoto
- `services/profile_service.dart` → getMyProfile, updateProfile, updatePhotos, deletePhoto, reverify, getHobbies, getOtherProfile
- `providers/profile_provider.dart`

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `my_profile.dart` | MyProfile (pure entity) |
| domain/entities | `other_profile.dart` | OtherProfile (pure entity) |
| domain/repositories | `profile_repository.dart` | abstract getMe, update, getOther |
| domain/usecases | `get_my_profile_usecase.dart` | |
| domain/usecases | `update_profile_usecase.dart` | |
| data/models | `my_profile_model.dart` | MyProfile DTO + toEntity |
| data/models | `other_profile_model.dart` | OtherProfile DTO + toEntity |
| data/datasources | `profile_remote_datasource.dart` | 현재 profile_service |
| data/repositories | `profile_repository_impl.dart` | |
| presentation/providers | `profile_provider.dart` | state management only |
| presentation/screens | `profile_detail_screen.dart` | 기존 이동 |

**Shared extraction:** `HobbyItem` → `shared/domain/entities/hobby.dart`, `PhotoItem` → `shared/domain/entities/photo.dart`

### 3.3 relationship

**Current:**
- `models/relationship_models.dart` → RelationshipItem, RelationshipDetail, RelationshipOtherUser, RelationshipDetailUser, RelationshipHobby, RelationshipPhoto, EncounterLocation
- `services/relationship_service.dart` → getList, getDetail, request/cancel/accept/reject/delete/convert/restore
- `providers/relationship_provider.dart` → state + business logic

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `relationship.dart` | Relationship (pure entity) |
| domain/entities | `relationship_detail.dart` | RelationshipDetail entity |
| domain/entities | `encounter_location.dart` | EncounterLocation entity |
| domain/repositories | `relationship_repository.dart` | abstract all operations |
| domain/usecases | `load_relationships_usecase.dart` | |
| domain/usecases | `request_inyeon_usecase.dart` | |
| domain/usecases | `manage_relationship_usecase.dart` | accept/reject/delete/convert/restore |
| data/models | `relationship_item_model.dart` | DTO + toEntity |
| data/models | `relationship_detail_model.dart` | DTO + toEntity |
| data/datasources | `relationship_remote_datasource.dart` | 현재 relationship_service |
| data/repositories | `relationship_repository_impl.dart` | |
| presentation/providers | `relationship_provider.dart` | state only |

### 3.4 chat

**Current:**
- `models/chat_models.dart` → ChatRoom, ChatMessage
- `services/chat_service.dart` → Firestore direct access (not ApiClient)
- `providers/chat_provider.dart`

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `chat_room.dart` | ChatRoom entity |
| domain/entities | `chat_message.dart` | ChatMessage entity |
| domain/repositories | `chat_repository.dart` | abstract stream/send/markRead |
| domain/usecases | `send_message_usecase.dart` | |
| domain/usecases | `get_chat_rooms_usecase.dart` | |
| data/datasources | `chat_firestore_datasource.dart` | 현재 chat_service (Firestore) |
| data/models | `chat_room_model.dart` | Firestore DTO + toEntity |
| data/models | `chat_message_model.dart` | Firestore DTO + toEntity |
| data/repositories | `chat_repository_impl.dart` | |
| presentation/providers | `chat_provider.dart` | |
| presentation/screens | `chat_list_screen.dart`, `chat_room_screen.dart` | |

**Note:** ChatService는 ApiClient가 아닌 Firestore를 사용. DataSource 추상화로 Firestore 의존성 격리.

### 3.5 location

**Current:**
- `models/location_models.dart` → ExcludedArea, H3CellInfo, H3GridResponse, LocationToggleResponse
- `services/location_service.dart` → sendLocation, toggle, listExcluded, addExcluded, deleteExcluded, getH3Grid, saveExcludedCells
- `providers/location_provider.dart`

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `excluded_area.dart` | ExcludedArea entity |
| domain/entities | `h3_grid.dart` | H3CellInfo, H3Grid entities |
| domain/repositories | `location_repository.dart` | abstract all operations |
| domain/usecases | `send_location_usecase.dart` | |
| domain/usecases | `manage_excluded_area_usecase.dart` | |
| data/models | `excluded_area_model.dart` | DTO + toEntity |
| data/models | `h3_grid_model.dart` | DTO + toEntity |
| data/datasources | `location_remote_datasource.dart` | 현재 location_service |
| data/repositories | `location_repository_impl.dart` | |
| presentation/providers | `location_provider.dart` | |

### 3.6 notification

**Current:**
- `models/notification_models.dart` → NotificationItem
- `services/notification_service.dart` → getList, markRead, deleteAll, updateFcmToken
- `providers/notification_provider.dart`
- `screens/notification_screen.dart`

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `notification_item.dart` | NotificationItem entity |
| domain/repositories | `notification_repository.dart` | abstract |
| domain/usecases | `get_notifications_usecase.dart` | |
| domain/usecases | `mark_notifications_read_usecase.dart` | |
| data/models | `notification_item_model.dart` | DTO + toEntity |
| data/datasources | `notification_remote_datasource.dart` | 현재 notification_service |
| data/repositories | `notification_repository_impl.dart` | |
| presentation/providers | `notification_provider.dart` | |
| presentation/screens | `notification_screen.dart` | |

### 3.7 settings

**Current:**
- `models/settings_models.dart` → MatchingSettings, NotificationSettings
- `services/settings_service.dart` → getMatching, updateMatching, getNotification, updateNotification
- `providers/settings_provider.dart`
- `screens/` → 6 screens

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `matching_settings.dart` | MatchingSettings entity |
| domain/entities | `notification_settings.dart` | NotificationSettings entity |
| domain/repositories | `settings_repository.dart` | abstract |
| domain/usecases | `get_settings_usecase.dart` | |
| domain/usecases | `update_settings_usecase.dart` | |
| data/models | `matching_settings_model.dart` | DTO + toEntity + toJson |
| data/models | `notification_settings_model.dart` | DTO + toEntity + toJson |
| data/datasources | `settings_remote_datasource.dart` | 현재 settings_service |
| data/repositories | `settings_repository_impl.dart` | |
| presentation/providers | `settings_provider.dart` | |
| presentation/screens | (기존 6 screens 이동) | |

### 3.8 shop

**Current:**
- `models/shop_models.dart` → KnotBalance, KnotPackage, PurchaseResponse, SubscriptionInfo, SubscriptionBenefits
- `services/shop_service.dart` → getKnots, getPackages, purchase, getSubscription, subscribe, cancelSubscription
- `providers/shop_provider.dart`

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `knot_balance.dart` | KnotBalance entity |
| domain/entities | `knot_package.dart` | KnotPackage entity |
| domain/entities | `subscription.dart` | SubscriptionInfo, SubscriptionBenefits entities |
| domain/repositories | `shop_repository.dart` | abstract |
| domain/usecases | `purchase_knots_usecase.dart` | |
| domain/usecases | `manage_subscription_usecase.dart` | |
| data/models | `knot_balance_model.dart` | DTO + toEntity |
| data/models | `knot_package_model.dart` | DTO + toEntity |
| data/models | `subscription_model.dart` | DTO + toEntity |
| data/datasources | `shop_remote_datasource.dart` | 현재 shop_service |
| data/repositories | `shop_repository_impl.dart` | |
| presentation/providers | `shop_provider.dart` | |

### 3.9 block

**Current:**
- `models/block_models.dart` → BlockItem, ReportRequest
- `services/block_service.dart` → listBlocks, blockUser, unblock, report
- `providers/block_provider.dart`

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `block_item.dart` | BlockItem entity |
| domain/repositories | `block_repository.dart` | abstract |
| domain/usecases | `block_user_usecase.dart` | |
| domain/usecases | `report_user_usecase.dart` | |
| data/models | `block_item_model.dart` | DTO + toEntity |
| data/models | `report_request_model.dart` | DTO |
| data/datasources | `block_remote_datasource.dart` | 현재 block_service |
| data/repositories | `block_repository_impl.dart` | |
| presentation/providers | `block_provider.dart` | |

### 3.10 system

**Current:**
- `models/system_models.dart` → VersionInfo, NicknameValidation
- `services/system_service.dart` → checkVersion, getHobbies, validateNickname

**Target:**

| Layer | File | Contents |
|-------|------|----------|
| domain/entities | `version_info.dart` | VersionInfo entity |
| domain/entities | `nickname_validation.dart` | NicknameValidation entity |
| domain/repositories | `system_repository.dart` | abstract |
| domain/usecases | `check_version_usecase.dart` | |
| domain/usecases | `validate_nickname_usecase.dart` | |
| data/models | `version_info_model.dart` | DTO + toEntity |
| data/datasources | `system_remote_datasource.dart` | 현재 system_service |
| data/repositories | `system_repository_impl.dart` | |

### 3.11 home, map, splash (Presentation-only)

These features have no business logic — they are purely presentation. They will remain as `presentation/` only, consuming other features' providers.

| Feature | Current | Target |
|---------|---------|--------|
| home | `screens/home_screen.dart`, `screens/tabs/` | `presentation/screens/`, `presentation/widgets/` |
| map | `screens/encounter_location_screen.dart`, `excluded_area_screen.dart`, `map_screen.dart` | `presentation/screens/` |
| splash | `screens/splash_screen.dart` | `presentation/screens/` |

### 3.12 contact_hash (Already Done)

No changes needed. Already follows Clean Architecture pattern.

---

## 4. Shared/Common Entities

Cross-feature에서 사용되는 모델을 `shared/` 또는 `core/`로 추출:

| Entity | Current Location | Used By | Target |
|--------|-----------------|---------|--------|
| `HobbyItem` | `auth/models/signup_models.dart` + `profile/models/profile_models.dart` | auth, profile, system, relationship | `shared/domain/entities/hobby.dart` |
| `PhotoItem` | `auth/models/signup_models.dart` | auth, profile | `shared/domain/entities/photo.dart` |
| `PageResponse` | `shared/models/page_response.dart` | relationship, notification | keep in `shared/models/` |
| `ApiResponse` | `shared/models/api_response.dart` | (unused directly) | keep in `shared/models/` |

---

## 5. Refactoring Order

의존성이 낮은 feature부터 진행. 각 feature는 Red-Green-Refactor 사이클로 검증.

### Phase 1: Domain Layer 분리 (Task #4)

**Step 1: Shared entities 추출**
1. `shared/domain/entities/hobby.dart` — HobbyItem → Hobby entity
2. `shared/domain/entities/photo.dart` — PhotoItem → Photo entity
3. `shared/data/models/hobby_model.dart` — HobbyItem DTO (fromJson/toJson/toEntity)
4. `shared/data/models/photo_model.dart` — PhotoItem DTO (fromJson/toJson/toEntity)

**Step 2: Independent features (다른 feature 의존 없음)**
1. **system** — 가장 단순, 외부 의존 없음 (2 entities, 1 service)
2. **block** — 단순, 독립적 (1 entity, 1 service)
3. **notification** — 단순, 독립적 (1 entity, 1 service)
4. **settings** — 단순, 독립적 (2 entities, 1 service)
5. **shop** — 독립적 (3 entities, 1 service)

**Step 3: Medium complexity features**
6. **location** — 독립적이나 model이 복잡 (4 entities, 1 service)
7. **profile** — shared hobby/photo 의존 (2 entities, 1 service)
8. **auth** — shared 의존 + OAuth 특수성 (2 entities, 4 services)

**Step 4: High complexity features**
9. **relationship** — 가장 복잡한 비즈니스 로직 (3 entities, 1 service, 11 API methods)
10. **chat** — Firestore 기반, 특수한 datasource (2 entities, 1 service)

**Step 5: Presentation-only features**
11. **home** — presentation 구조 정리 (tabs → widgets/)
12. **map** — presentation 구조 정리
13. **splash** — presentation 구조 정리

### Phase 2: Data/Presentation Layer 분리 (Task #6)

각 feature에 대해:
1. Service → DataSource + RepositoryImpl 분리
2. Model에 `toEntity()` 추가
3. Provider 리팩토링: Service 직접 의존 → Repository/UseCase 의존
4. `main.dart` Provider 등록 업데이트

### Phase 3: Test 정리 + 빌드 검증 (Task #7)

1. 기존 테스트가 깨지지 않는지 확인
2. 새 domain/data layer 단위 테스트 추가
3. `flutter analyze` + `dart format` 통과
4. 빌드 검증

---

## 6. Migration Strategy

### 6.1 점진적 마이그레이션 (Non-breaking)

한 번에 전체를 바꾸지 않고 feature별로 점진적 마이그레이션:

1. **Entity 생성**: `domain/entities/` 에 순수 entity 생성
2. **Model 업데이트**: 기존 model에 `toEntity()` 추가 (기존 코드 깨지지 않음)
3. **Repository 인터페이스**: `domain/repositories/` 에 abstract class 생성
4. **Repository 구현체**: 기존 Service를 DataSource로 감싸는 RepositoryImpl 생성
5. **UseCase 생성**: Repository를 사용하는 UseCase 생성
6. **Provider 업데이트**: Service → UseCase/Repository 의존으로 변경
7. **기존 Service 제거**: 모든 참조가 새 구조로 이전된 후 삭제

### 6.2 Import Path Convention

```dart
// Domain layer — no external dependencies
import 'package:itto_frontend/features/auth/domain/entities/user.dart';
import 'package:itto_frontend/features/auth/domain/repositories/auth_repository.dart';

// Data layer — depends on domain
import 'package:itto_frontend/features/auth/data/models/login_response_model.dart';
import 'package:itto_frontend/features/auth/data/repositories/auth_repository_impl.dart';

// Presentation layer — depends on domain (NOT data)
import 'package:itto_frontend/features/auth/presentation/providers/auth_provider.dart';
```

### 6.3 Dependency Rule

```
presentation → domain ← data
```

- `domain/` imports NOTHING from `data/` or `presentation/`
- `data/` imports from `domain/` (entities, repository interfaces)
- `presentation/` imports from `domain/` (entities, repository interfaces, usecases)
- `presentation/` NEVER imports from `data/`

---

## 7. DI Strategy

### Phase 1 (Current): Manual DI in main.dart

현재와 같이 `main.dart`에서 수동으로 의존성 주입. Repository 추상화만 추가:

```dart
// main.dart
final authDataSource = AuthRemoteDataSource(apiClient);
final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);
final loginUseCase = LoginUseCase(repository: authRepository, tokenStorage: tokenStorage);

ChangeNotifierProvider(
  create: (_) => AuthProvider(loginUseCase: loginUseCase, ...),
),
```

### Phase 2 (Future): get_it / injectable

충분히 안정화된 후 DI container 도입 고려 (현재 scope 밖).

---

## 8. File Count Estimate

| Feature | Current Files | Target Files | Delta |
|---------|:---:|:---:|:---:|
| auth | 18 | 28 | +10 |
| profile | 4 | 12 | +8 |
| relationship | 3 | 14 | +11 |
| chat | 4 | 12 | +8 |
| location | 3 | 12 | +9 |
| notification | 4 | 10 | +6 |
| settings | 8 | 14 | +6 |
| shop | 3 | 12 | +9 |
| block | 3 | 10 | +7 |
| system | 2 | 8 | +6 |
| contact_hash | 8 | 8 | 0 |
| home | 5 | 5 | 0 |
| map | 3 | 3 | 0 |
| splash | 1 | 1 | 0 |
| shared | 6 | 10 | +4 |
| **Total** | **75** | **159** | **+84** |

---

## 9. Risk & Mitigation

| Risk | Mitigation |
|------|------------|
| 기존 테스트 깨짐 | feature별 점진적 마이그레이션, import path 업데이트 |
| import 경로 대량 변경 | IDE 리팩토링 도구 활용, `dart fix` 사용 |
| Provider 등록 누락 | `main.dart` 변경 시 앱 빌드 테스트 필수 |
| cross-feature 의존성 | shared entity 먼저 추출하여 순환 의존 방지 |
| 파일 수 증가 | Clean Architecture의 의도된 결과, 각 파일의 단일 책임 보장 |
