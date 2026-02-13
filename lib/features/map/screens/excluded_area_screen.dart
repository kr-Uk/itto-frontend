import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../location/providers/location_provider.dart';

class ExcludedAreaScreen extends StatefulWidget {
  const ExcludedAreaScreen({super.key});

  @override
  State<ExcludedAreaScreen> createState() => _ExcludedAreaScreenState();
}

class _ExcludedAreaScreenState extends State<ExcludedAreaScreen> {
  final MapController _mapController = MapController();
  Timer? _debounceTimer;
  bool _initialLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialGrid();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialGrid() async {
    final locationProvider = context.read<LocationProvider>();
    try {
      final position = await locationProvider.getCurrentPosition();
      if (!mounted) return;
      await locationProvider.loadH3Grid(position.latitude, position.longitude);
      if (!mounted) return;
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );
      setState(() => _initialLoaded = true);
    } catch (e) {
      if (!mounted) return;
      // 기본 좌표 (서울)로 폴백
      await locationProvider.loadH3Grid(37.5665, 126.9780);
      if (!mounted) return;
      _mapController.move(const LatLng(37.5665, 126.9780), 15.0);
      setState(() => _initialLoaded = true);
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        final center = _mapController.camera.center;
        context.read<LocationProvider>().loadH3Grid(
              center.latitude,
              center.longitude,
            );
      });
    }
  }

  void _onTapMap(TapPosition tapPosition, LatLng point) {
    final locationProvider = context.read<LocationProvider>();
    final cells = locationProvider.gridCells;

    // 탭 좌표가 어느 셀에 속하는지 판별 (point-in-polygon)
    for (final cell in cells) {
      if (_isPointInPolygon(point, cell.boundary)) {
        locationProvider.toggleCell(cell.h3Index);
        if (locationProvider.error != null) {
          SnackBarUtils.showError(context, locationProvider.error!);
          locationProvider.clearError();
        }
        return;
      }
    }
  }

  bool _isPointInPolygon(LatLng point, List<List<double>> polygon) {
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      final yi = polygon[i][0];
      final xi = polygon[i][1];
      final yj = polygon[j][0];
      final xj = polygon[j][1];

      if (((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  Future<void> _save() async {
    final locationProvider = context.read<LocationProvider>();
    final success = await locationProvider.saveExcludedCells();
    if (!mounted) return;
    if (success) {
      SnackBarUtils.showSuccess(context, '제외 지역이 저장되었습니다');
      Navigator.of(context).pop();
    } else {
      SnackBarUtils.showError(
          context, locationProvider.error ?? '저장에 실패했습니다');
    }
  }

  void _clearAll() {
    context.read<LocationProvider>().clearSelectedCells();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '제외 지역 설정'),
      body: Column(
        children: [
          Expanded(
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                final cells = locationProvider.gridCells;
                final selected = locationProvider.selectedCells;

                return Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: const LatLng(37.5665, 126.9780),
                        initialZoom: 15.0,
                        minZoom: 13.0,
                        maxZoom: 18.0,
                        onTap: _onTapMap,
                        onMapEvent: _onMapEvent,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.itto.app',
                        ),
                        PolygonLayer(
                          polygons: cells.map((cell) {
                            final isSelected = selected.contains(cell.h3Index);
                            final points = cell.boundary
                                .map((p) => LatLng(p[0], p[1]))
                                .toList();
                            return Polygon(
                              points: points,
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderColor: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.withValues(alpha: 0.4),
                              borderStrokeWidth: isSelected ? 2.0 : 1.0,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // 로딩 인디케이터
                    if (locationProvider.isGridLoading || !_initialLoaded)
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
                    // 안내 텍스트
                    Positioned(
                      top: 12,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '지도에서 제외할 영역을 탭하세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // 하단 바
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, _) {
                final count = locationProvider.selectedCells.length;
                return Row(
                  children: [
                    Text(
                      '$count/20 선택됨',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAll,
                      child: const Text(
                        '초기화',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: locationProvider.isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: locationProvider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '저장',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
