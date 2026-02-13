import 'package:flutter/foundation.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:intl/intl.dart';
import '../../../core/network/api_exception.dart';
import '../models/location_models.dart';
import '../services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _service;

  bool _isMatchingEnabled = false;
  List<ExcludedArea> _excludedAreas = [];
  bool _isLoading = false;
  String? _error;
  bool _isPluginReady = false;

  LocationProvider({required LocationService service}) : _service = service;

  bool get isMatchingEnabled => _isMatchingEnabled;
  List<ExcludedArea> get excludedAreas => _excludedAreas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// flutter_background_geolocation 플러그인 초기화 (앱 시작 시 1회)
  Future<void> initBackgroundGeolocation() async {
    if (_isPluginReady) return;

    // 위치 이벤트 리스너
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      _onLocation(location);
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      if (kDebugMode) {
        print('[BGGeo] motionchange: isMoving=${location.isMoving}');
      }
    });

    bg.BackgroundGeolocation.onProviderChange(
        (bg.ProviderChangeEvent event) {
      if (kDebugMode) {
        print('[BGGeo] providerchange: $event');
      }
    });

    // 플러그인 설정
    bg.State state = await bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 30.0, // 30m 이동마다 위치 업데이트

      // 백그라운드 + 앱 종료 후에도 추적 유지
      stopOnTerminate: false,
      startOnBoot: true,
      enableHeadless: true,

      // Android 포어그라운드 서비스
      foregroundService: true,
      notification: bg.Notification(
        title: 'Itto',
        text: '인연을 찾고 있습니다',
        channelName: 'Itto 위치 서비스',
      ),

      // 위치 업데이트 주기 (Android)
      locationUpdateInterval: 30000, // 30초
      fastestLocationUpdateInterval: 15000, // 최소 15초

      // 디버그
      debug: kDebugMode,
      logLevel: kDebugMode
          ? bg.Config.LOG_LEVEL_VERBOSE
          : bg.Config.LOG_LEVEL_OFF,
    ));

    _isPluginReady = true;

    if (kDebugMode) {
      print('[BGGeo] ready: enabled=${state.enabled}');
    }

    // 플러그인이 이미 추적 중이면 매칭 상태 동기화
    if (state.enabled) {
      _isMatchingEnabled = true;
      notifyListeners();
    }
  }

  /// 위치 이벤트 수신 → 서버 전송
  void _onLocation(bg.Location location) {
    final timestamp =
        DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now());

    _service
        .sendLocation(
      h3Index: 'placeholder', // H3는 서버에서 계산
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
      accuracy: location.coords.accuracy,
      timestamp: timestamp,
    )
        .catchError((e) {
      if (kDebugMode) {
        print('[BGGeo] 위치 전송 실패: $e');
      }
    });
  }

  /// 인연 만나기 토글
  Future<bool> toggleMatching(bool enabled) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _service.toggle(enabled);
      _isMatchingEnabled = response.enabled;

      if (_isMatchingEnabled) {
        await startLocationTracking();
      } else {
        await stopLocationTracking();
      }

      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 위치 추적 시작 (포그라운드 + 백그라운드 모두)
  Future<void> startLocationTracking() async {
    if (!_isPluginReady) {
      await initBackgroundGeolocation();
    }
    await bg.BackgroundGeolocation.start();
    if (kDebugMode) {
      print('[BGGeo] tracking started');
    }
  }

  /// 위치 추적 중지
  Future<void> stopLocationTracking() async {
    await bg.BackgroundGeolocation.stop();
    if (kDebugMode) {
      print('[BGGeo] tracking stopped');
    }
  }

  /// 현재 위치 1회 조회 (제외 지역 추가 등에서 사용)
  Future<({double latitude, double longitude})> getCurrentPosition() async {
    if (!_isPluginReady) {
      await initBackgroundGeolocation();
    }

    final bg.Location location =
        await bg.BackgroundGeolocation.getCurrentPosition(
      samples: 1,
      timeout: 30,
      maximumAge: 5000,
      desiredAccuracy: 10,
    );

    return (
      latitude: location.coords.latitude,
      longitude: location.coords.longitude,
    );
  }

  // ========== H3 그리드 / 제외 셀 관련 ==========

  Set<String> _selectedCells = {};
  List<H3CellInfo> _gridCells = [];
  bool _isGridLoading = false;

  Set<String> get selectedCells => _selectedCells;
  List<H3CellInfo> get gridCells => _gridCells;
  bool get isGridLoading => _isGridLoading;

  Future<void> loadH3Grid(double lat, double lng) async {
    _isGridLoading = true;
    notifyListeners();
    try {
      final response = await _service.getH3Grid(latitude: lat, longitude: lng);
      _gridCells = response.cells;
      _selectedCells = response.selectedIndexes.toSet();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isGridLoading = false;
      notifyListeners();
    }
  }

  bool toggleCell(String h3Index) {
    if (_selectedCells.contains(h3Index)) {
      _selectedCells = {..._selectedCells}..remove(h3Index);
      notifyListeners();
      return true;
    } else {
      if (_selectedCells.length >= 20) {
        _error = '제외 셀은 최대 20개까지 선택할 수 있습니다';
        notifyListeners();
        return false;
      }
      _selectedCells = {..._selectedCells, h3Index};
      notifyListeners();
      return true;
    }
  }

  void clearSelectedCells() {
    _selectedCells = {};
    notifyListeners();
  }

  Future<bool> saveExcludedCells() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.saveExcludedCells(_selectedCells.toList());
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== 제외 지역 관련 (기존) ==========

  Future<void> loadExcludedAreas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _excludedAreas = await _service.listExcluded();
    } on ApiException catch (e) {
      _error = e.userMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExcludedArea({
    required String name,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final area = await _service.addExcluded(
        name: name,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      _excludedAreas = [..._excludedAreas, area];
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteExcludedArea(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.deleteExcluded(id);
      _excludedAreas = _excludedAreas.where((a) => a.id != id).toList();
      return true;
    } on ApiException catch (e) {
      _error = e.userMessage;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // 플러그인은 stopOnTerminate:false이므로 dispose에서 중지하지 않음
    super.dispose();
  }
}
