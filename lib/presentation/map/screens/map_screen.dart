import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/domain/relationship/entities/encounter_heatmap.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/presentation/common/widgets/itto_app_bar.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  NaverMapController? _mapController;
  EncounterHeatmap? _heatmap;
  bool _isLoading = false;
  double? _myLat;
  double? _myLng;

  static const _defaultCenter = NLatLng(37.5665, 126.9780);

  Future<void> _onMapReady(NaverMapController controller) async {
    _mapController = controller;
    await _initHeatmap();
  }

  Future<void> _initHeatmap() async {
    setState(() => _isLoading = true);
    try {
      final position =
          await ref.read(locationChangeNotifierProvider).getCurrentPosition();
      if (!mounted) return;
      _myLat = position.latitude;
      _myLng = position.longitude;
    } catch (_) {
      _myLat = _defaultCenter.latitude;
      _myLng = _defaultCenter.longitude;
    }

    try {
      final heatmap = await ref
          .read(relationshipChangeNotifierProvider)
          .getEncounterHeatmap(latitude: _myLat!, longitude: _myLng!);
      if (!mounted) return;
      setState(() {
        _heatmap = heatmap;
        _isLoading = false;
      });
      await _mapController?.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(_myLat!, _myLng!),
          zoom: 14,
        ),
      );
      _drawHeatmap();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      SnackBarUtils.showError(context, '주변 데이터를 불러오지 못했어요');
    }
  }

  void _drawHeatmap() {
    final controller = _mapController;
    final heatmap = _heatmap;
    if (controller == null || heatmap == null) return;

    controller.clearOverlays(type: NOverlayType.polygonOverlay);

    for (int i = 0; i < heatmap.cells.length; i++) {
      final cell = heatmap.cells[i];
      if (cell.count <= 0) continue;

      final coords = cell.boundary.map((p) => NLatLng(p[0], p[1])).toList();
      if (coords.isNotEmpty && coords.first != coords.last) {
        coords.add(coords.first);
      }

      final colorStop = _intensityFor(cell.count);
      controller.addOverlay(
        NPolygonOverlay(
          id: 'heat_${cell.h3Index}',
          coords: coords,
          color: AppColors.accent.withValues(alpha: colorStop),
          outlineColor: AppColors.accent.withValues(alpha: 0.7),
          outlineWidth: 1,
        ),
      );
    }
  }

  /// count → 폴리곤 alpha. 정확한 숫자 노출 없이 강도만 단계화.
  double _intensityFor(int count) {
    if (count >= 6) return 0.55;
    if (count >= 3) return 0.4;
    return 0.22;
  }

  Future<void> _recenter() async {
    if (_myLat == null || _myLng == null) return;
    await _mapController?.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(_myLat!, _myLng!),
        zoom: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cellsWithCount =
        _heatmap?.cells.where((c) => c.count > 0).toList() ?? const [];
    final totalEncounters = cellsWithCount.fold<int>(0, (s, c) => s + c.count);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '인연 위치 찾기'),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                NaverMap(
                  options: const NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: _defaultCenter,
                      zoom: 14,
                    ),
                    mapType: NMapType.basic,
                    locationButtonEnable: false,
                  ),
                  onMapReady: _onMapReady,
                ),
                if (_isLoading)
                  const Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 14,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tabBarBackground.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '정확한 위치 대신 동네 단위로 표시돼요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textMid,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: AppColors.surface,
                    elevation: 4,
                    onPressed: _recenter,
                    child: const Icon(
                      Icons.my_location,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              14 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.pillGradient,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cellsWithCount.isEmpty
                            ? '아직 마주친 인연이 없어요'
                            : '${cellsWithCount.length}곳에서 $totalEncounters번 마주쳤어요',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '진한 헥사곤일수록 자주 마주친 동네예요.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
