# flutter_map → flutter_naver_map 마이그레이션

## 날짜
2026-02-19

## 작업 요약
OSM 기반 flutter_map을 네이버맵(flutter_naver_map)으로 교체하여 한국 지도 품질 개선.
3개 지도 화면(지도, 만남위치, 제외지역) 모두 마이그레이션 완료.

## 변경 파일 (8개)
| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | flutter_map + latlong2 제거, flutter_naver_map ^1.3.0 추가 (1.4.4 설치됨) |
| `.env` | NAVER_MAP_CLIENT_ID 환경변수 추가 |
| `AndroidManifest.xml` | com.naver.maps.map.CLIENT_ID meta-data 추가 |
| `main.dart` | FlutterNaverMap().init() SDK 초기화 |
| `map_screen.dart` | 250줄 플레이스홀더 → 25줄 NaverMap 위젯 |
| `encounter_location_screen.dart` | FlutterMap → NaverMap, Marker → NMarker |
| `excluded_area_screen.dart` | 선언적 → 명령적 패턴 전환 (가장 복잡) |
| `build.gradle.kts` | play-services-location 버전 충돌 해결 |

## 핵심 학습: 선언적 vs 명령적 패턴

### flutter_map (선언적)
위젯 트리에 레이어를 선언하면 Flutter rebuild 시 자동 갱신.
```dart
FlutterMap(
  children: [
    TileLayer(urlTemplate: '...'),
    PolygonLayer(polygons: [...]),  // 데이터 바뀌면 자동 rebuild
  ],
)
```

### flutter_naver_map (명령적)
NaverMapController를 통해 직접 오버레이를 추가/삭제.
```dart
NaverMap(
  onMapReady: (controller) {
    _mapController = controller;
    controller.addOverlay(NPolygonOverlay(...));
  },
)
```

**결론**: flutter_naver_map에서는 상태가 바뀔 때마다 `clearOverlays()` + `addOverlay()` 메서드를 직접 호출해야 함.

## API 매핑 표

| flutter_map | flutter_naver_map |
|------------|-------------------|
| `MapController()` | `NaverMapController?` (onMapReady 콜백) |
| `LatLng(lat, lng)` | `NLatLng(lat, lng)` |
| `MapOptions(initialCenter:)` | `NaverMapViewOptions(initialCameraPosition:)` |
| `mapController.move(latLng, zoom)` | `controller.updateCamera(NCameraUpdate.scrollAndZoomTo(...))` |
| `mapController.camera.center` | `await controller.getCameraPosition()` → `.target` |
| `Marker(point:, child:)` | `NMarker(id:, position:)` |
| `PolygonLayer(polygons:)` | `controller.addOverlay(NPolygonOverlay(...))` |
| `Polygon(points:, color:, borderColor:)` | `NPolygonOverlay(coords:, color:, outlineColor:)` |
| `MapOptions(onTap:)` | `NaverMap(onMapTapped:)` |
| `MapOptions(onMapEvent:)` → `MapEventMoveEnd` | `NaverMap(onCameraIdle:)` |
| `TileLayer(urlTemplate:)` | 불필요 (네이버맵 자체 타일) |

## 네이버 클라우드 플랫폼 설정

### Client ID 발급 경로
1. https://console.ncloud.com 로그인
2. 좌측 **Services** → **Application Services** → **Maps** (AI·NAVER API가 아님!)
3. 또는 직접: https://console.ncloud.com/maps/application
4. **Application 등록** → **Mobile Dynamic Map** 체크
5. Android 패키지명: `com.itto.app`
6. 등록 후 **인증 정보**에서 Client ID 확인

### 적용 위치 (2곳)
- `.env` → `NAVER_MAP_CLIENT_ID=xxx`
- `AndroidManifest.xml` → `<meta-data android:name="com.naver.maps.map.CLIENT_ID" android:value="xxx" />`

## 트러블슈팅

### 1. NaverMapSdk deprecated
```
'NaverMapSdk' is deprecated. Use FlutterNaverMap class instead.
```
**해결**: `NaverMapSdk.instance.initialize(...)` → `FlutterNaverMap().init(...)`
- 주의: `init`은 인스턴스 메서드 (static 아님)

### 2. play-services-location 버전 충돌
```
java.lang.IncompatibleClassChangeError: Found interface
com.google.android.gms.location.FusedLocationProviderClient, but class was expected
```
**원인**: flutter_naver_map이 play-services-location 21.3.0을 끌어오는데, flutter_background_geolocation은 20.0.0 기대.
21.x에서 FusedLocationProviderClient가 class → interface로 변경됨.

**해결**: `android/app/build.gradle.kts`에 버전 고정:
```kotlin
configurations.all {
    resolutionStrategy {
        force("com.google.android.gms:play-services-location:20.0.0")
    }
}
```

### 3. onMapReady 타이밍
NaverMapController는 생성자에서 받을 수 없고 `onMapReady` 콜백에서만 수신 가능.
→ `NaverMapController?` nullable로 선언하고, null-safe 호출 (`_mapController?.updateCamera(...)`)

### 4. 폴리곤 닫힘 확인
네이버맵 NPolygonOverlay는 첫 점과 마지막 점이 같아야 정상 렌더링.
```dart
if (coords.isNotEmpty && coords.first != coords.last) {
  coords.add(coords.first);
}
```

## 참고 링크
- flutter_naver_map 패키지: https://pub.dev/packages/flutter_naver_map
- 네이버 클라우드 Maps 콘솔: https://console.ncloud.com/maps/application
