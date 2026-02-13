import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../../shared/widgets/purple_button.dart';
import '../../location/providers/location_provider.dart';
import '../../location/models/location_models.dart';

class ExcludedAreaScreen extends StatefulWidget {
  const ExcludedAreaScreen({super.key});

  @override
  State<ExcludedAreaScreen> createState() => _ExcludedAreaScreenState();
}

class _ExcludedAreaScreenState extends State<ExcludedAreaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadExcludedAreas();
    });
  }

  void _addArea() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddAreaBottomSheet(),
    );
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
                final areas = locationProvider.excludedAreas;

                if (locationProvider.isLoading && areas.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- Heading --
                      Text(
                        '제외된 지역 목록 ${areas.length}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '설정한 지역에서는 인연을 찾지 않습니다.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // -- Area list --
                      for (int i = 0; i < areas.length; i++) ...[
                        _AreaCard(
                          area: areas[i],
                          onDelete: () {
                            locationProvider.deleteExcludedArea(areas[i].id);
                          },
                        ),
                        if (i < areas.length - 1)
                          const SizedBox(height: 10),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // -- Add button --
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: PurpleButton(
              text: '추가하기',
              onPressed: _addArea,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Area Bottom Sheet
// ---------------------------------------------------------------------------

class _AddAreaBottomSheet extends StatefulWidget {
  const _AddAreaBottomSheet();

  @override
  State<_AddAreaBottomSheet> createState() => _AddAreaBottomSheetState();
}

class _AddAreaBottomSheetState extends State<_AddAreaBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedPreset;
  double? _latitude;
  double? _longitude;
  int _selectedRadius = 500; // Default 500m
  bool _isLoadingLocation = false;

  final List<String> _presets = ['학교', '집', '회사', '기타'];
  final List<int> _radiusOptions = [100, 200, 500, 1000];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // LocationProvider.getCurrentPosition()으로 위치 조회
      // (flutter_background_geolocation이 권한 요청까지 자동 처리)
      final locationProvider = context.read<LocationProvider>();
      final position = await locationProvider.getCurrentPosition();

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showError(context, '위치를 가져오는데 실패했습니다: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _submit() async {
    // Validation
    final name = _selectedPreset ?? _nameController.text.trim();
    if (name.isEmpty) {
      SnackBarUtils.showError(context, '지역 이름을 입력해주세요.');
      return;
    }

    if (_latitude == null || _longitude == null) {
      SnackBarUtils.showError(context, '위치를 선택해주세요.');
      return;
    }

    final locationProvider = context.read<LocationProvider>();
    final success = await locationProvider.addExcludedArea(
      name: name,
      latitude: _latitude!,
      longitude: _longitude!,
      radius: _selectedRadius,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      SnackBarUtils.showSuccess(context, '제외 지역이 추가되었습니다.');
    } else {
      SnackBarUtils.showError(context, locationProvider.error ?? '제외 지역 추가에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                '제외 지역 추가',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // Area name - Preset chips
              const Text(
                '지역 이름',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((preset) {
                  final isSelected = _selectedPreset == preset;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPreset = preset;
                        _nameController.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        preset,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Custom name input
              TextField(
                controller: _nameController,
                enabled: _selectedPreset == null,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _selectedPreset = null;
                    });
                  }
                },
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '또는 직접 입력',
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Location selection
              const Text(
                '위치',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _useCurrentLocation,
                icon: _isLoadingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(_isLoadingLocation ? '위치 가져오는 중...' : '현재 위치 사용'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '위도: ${_latitude!.toStringAsFixed(6)}\n경도: ${_longitude!.toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Radius selection
              const Text(
                '반경',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _radiusOptions.map((radius) {
                  final isSelected = _selectedRadius == radius;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRadius = radius;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${radius}m',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Submit button
              Consumer<LocationProvider>(
                builder: (context, locationProvider, _) {
                  return PurpleButton(
                    text: '추가',
                    onPressed: locationProvider.isLoading ? null : _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Area card
// ---------------------------------------------------------------------------

class _AreaCard extends StatelessWidget {
  final ExcludedArea area;
  final VoidCallback onDelete;

  const _AreaCard({
    required this.area,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Tag badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _tagColor(area.name).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              area.name,
              style: TextStyle(
                color: _tagColor(area.name),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Radius info
          Expanded(
            child: Text(
              '반경 ${area.radius}m',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.delete_outline,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case '학교':
        return const Color(0xFF60A5FA); // blue
      case '집':
        return const Color(0xFF34D399); // green
      case '병원':
        return const Color(0xFFF87171); // red
      default:
        return AppColors.primary;
    }
  }
}
