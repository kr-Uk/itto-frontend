import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../../shared/widgets/itto_dialog.dart';
import '../../../shared/widgets/purple_button.dart';
import '../providers/settings_provider.dart';
import '../models/settings_models.dart';
import '../../block/providers/block_provider.dart';

class ConnectionRangeScreen extends StatefulWidget {
  const ConnectionRangeScreen({super.key});

  @override
  State<ConnectionRangeScreen> createState() => _ConnectionRangeScreenState();
}

class _ConnectionRangeScreenState extends State<ConnectionRangeScreen> {
  // -- Gender selection --
  // 0 = female, 1 = male
  int _selectedGender = 0;

  // -- Age range --
  // Mapped to decades: 20=0, 30=1, 40=2, 50=3, 60+=4
  // Subdivisions: 초반/중반/후반 (early/mid/late)
  // We use a double range 0..12 representing 20초반..60이상
  static const List<String> _ageLabels = [
    '20대 초반',
    '20대 중반',
    '20대 후반',
    '30대 초반',
    '30대 중반',
    '30대 후반',
    '40대 초반',
    '40대 중반',
    '40대 후반',
    '50대 초반',
    '50대 중반',
    '50대 후반',
    '60대 이상',
  ];

  // Map slider index to actual age value
  static const List<int> _ageValues = [
    20,
    22,
    27,
    30,
    33,
    37,
    40,
    43,
    47,
    50,
    53,
    57,
    60,
  ];

  RangeValues _ageRange = const RangeValues(3, 9); // 30대 초반 - 50대 초반

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadMatchingSettings();
      context.read<BlockProvider>().loadBlocks();
    });
  }

  void _initFromSettings() {
    if (_initialized) return;
    final settings = context.read<SettingsProvider>().matchingSettings;
    if (settings != null) {
      // Map gender string to index
      if (settings.genderFilter == 'FEMALE') {
        _selectedGender = 0;
      } else if (settings.genderFilter == 'MALE') {
        _selectedGender = 1;
      }

      // Map age values to slider indices
      _ageRange = RangeValues(
        _ageToSliderIndex(settings.ageRangeMin).toDouble(),
        _ageToSliderIndex(settings.ageRangeMax).toDouble(),
      );
      _initialized = true;
    }
  }

  /// Find the closest slider index for a given age value
  int _ageToSliderIndex(int age) {
    int bestIdx = 0;
    int bestDiff = (age - _ageValues[0]).abs();
    for (int i = 1; i < _ageValues.length; i++) {
      final diff = (age - _ageValues[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  String get _ageLabelStart =>
      _ageLabels[_ageRange.start.round().clamp(0, _ageLabels.length - 1)];
  String get _ageLabelEnd =>
      _ageLabels[_ageRange.end.round().clamp(0, _ageLabels.length - 1)];

  Future<void> _showUnblockDialog(int blockId, String nickname) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => IttoDialog(
        title: "'$nickname'님의\n차단을 해제하시겠습니까?",
        subtitle: '해제하면 다시 서로 노출됩니다.',
        cancelText: '취소',
        confirmText: '해제하기',
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context.read<BlockProvider>().unblock(blockId);
    if (!mounted) return;

    if (success) {
      SnackBarUtils.showSuccess(context, '차단이 해제되었습니다.');
    } else {
      SnackBarUtils.showError(
        context,
        context.read<BlockProvider>().error ?? '차단 해제에 실패했습니다.',
      );
    }
  }

  void _save() {
    final genderFilter = _selectedGender == 0 ? 'FEMALE' : 'MALE';
    final ageMin =
        _ageValues[_ageRange.start.round().clamp(0, _ageValues.length - 1)];
    final ageMax =
        _ageValues[_ageRange.end.round().clamp(0, _ageValues.length - 1)];

    context.read<SettingsProvider>().updateMatchingSettings(
      MatchingSettings(
        genderFilter: genderFilter,
        ageRangeMin: ageMin,
        ageRangeMax: ageMax,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        _initFromSettings();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const IttoAppBar(title: '인연 범위 설정'),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- Subtitle --
                      const Text(
                        '내가 만나고 싶은 인연의 범위를 설정할 수 있어요.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // -- Gender section --
                      _sectionTitle('성별'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _GenderButton(
                              label: '여자',
                              selected: _selectedGender == 0,
                              onTap: () => setState(() => _selectedGender = 0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _GenderButton(
                              label: '남자',
                              selected: _selectedGender == 1,
                              onTap: () => setState(() => _selectedGender = 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // -- Age range section --
                      _sectionTitle('연령대'),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '$_ageLabelStart - $_ageLabelEnd',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.surfaceLight,
                          thumbColor: Colors.white,
                          overlayColor: AppColors.primary.withValues(
                            alpha: 0.15,
                          ),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                          rangeThumbShape: const RoundRangeSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                        ),
                        child: RangeSlider(
                          values: _ageRange,
                          min: 0,
                          max: (_ageLabels.length - 1).toDouble(),
                          divisions: _ageLabels.length - 1,
                          onChanged: (values) {
                            setState(() => _ageRange = values);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final label in [
                              '20대',
                              '30대',
                              '40대',
                              '50대',
                              '60대 이상',
                            ])
                              Text(
                                label,
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // -- Excluded area --
                      _sectionTitle('제외 지역 설정'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '제외할 지역을 설정하세요',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/map/excluded'),
                              child: const Text(
                                '자세히 보기',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // -- Blocked users --
                      _sectionTitle('차단하기'),
                      const SizedBox(height: 10),
                      Consumer<BlockProvider>(
                        builder: (context, blockProvider, _) {
                          final blocks = blockProvider.blocks;

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                // Table header
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: const [
                                      Expanded(
                                        child: Text(
                                          '이름',
                                          style: TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '차단일',
                                          style: TextStyle(
                                            color: AppColors.textTertiary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 0.5,
                                  thickness: 0.5,
                                  color: AppColors.divider,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                                // Table rows
                                if (blocks.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      '차단된 사용자가 없습니다',
                                      style: TextStyle(
                                        color: AppColors.textTertiary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                for (final block in blocks)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            block.blockedUser.nickname,
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            block.createdAt.length >= 10
                                                ? block.createdAt.substring(
                                                    0,
                                                    10,
                                                  )
                                                : block.createdAt,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _showUnblockDialog(
                                            block.id,
                                            block.blockedUser.nickname,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.textTertiary,
                                                width: 0.5,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              '해제',
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // -- Save button --
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: PurpleButton(text: '저장하기', onPressed: _save),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gender toggle button
// ---------------------------------------------------------------------------

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? null
              : Border.all(color: AppColors.divider, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppColors.textSecondary,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
