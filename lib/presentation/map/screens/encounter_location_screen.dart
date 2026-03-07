import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_app_bar.dart';
import 'package:itto/domain/relationship/entities/encounter_location.dart';

class EncounterLocationScreen extends ConsumerStatefulWidget {
  final int relationshipId;

  const EncounterLocationScreen({super.key, required this.relationshipId});

  @override
  ConsumerState<EncounterLocationScreen> createState() =>
      _EncounterLocationScreenState();
}

class _EncounterLocationScreenState extends ConsumerState<EncounterLocationScreen> {
  EncounterLocation? _location;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEncounterLocation();
  }

  Future<void> _loadEncounterLocation() async {
    try {
      final provider = ref.read(relationshipChangeNotifierProvider);
      final location = await provider.getEncounterLocation(
        widget.relationshipId,
      );
      if (!mounted) return;
      setState(() {
        _location = location;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '만남 위치를 불러오는데 실패했습니다';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy년 M월 d일 HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  void _onMapReady(NaverMapController controller) {
    if (_location?.latitude == null || _location?.longitude == null) return;

    final position = NLatLng(_location!.latitude!, _location!.longitude!);
    final marker = NMarker(id: 'encounter', position: position);
    marker.setCaption(const NOverlayCaption(text: '만남 위치'));
    marker.setIconTintColor(AppColors.primary);
    controller.addOverlay(marker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '만남 위치'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : _location?.latitude == null || _location?.longitude == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    color: AppColors.textTertiary,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '만남 위치 정보가 없습니다',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: NaverMap(
                    options: NaverMapViewOptions(
                      initialCameraPosition: NCameraPosition(
                        target: NLatLng(
                          _location!.latitude!,
                          _location!.longitude!,
                        ),
                        zoom: 16,
                      ),
                    ),
                    onMapReady: _onMapReady,
                  ),
                ),
                // 하단 정보 패널
                Container(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.divider, width: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_location!.encounterAt != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '만남 시간: ${_formatDate(_location!.encounterAt)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.textTertiary,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '약 100m 범위 내 위치입니다',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
