import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../../shared/widgets/purple_button.dart';

class ExcludedAreaScreen extends StatefulWidget {
  const ExcludedAreaScreen({super.key});

  @override
  State<ExcludedAreaScreen> createState() => _ExcludedAreaScreenState();
}

class _ExcludedAreaScreenState extends State<ExcludedAreaScreen> {
  final List<_ExcludedArea> _areas = [
    const _ExcludedArea(
      tag: '학교',
      address: '경북 포항시 한동로 558',
    ),
    const _ExcludedArea(
      tag: '집',
      address: '대구 수성구 달구벌대로',
    ),
    const _ExcludedArea(
      tag: '병원',
      address: '용인 수지구 포은대로',
    ),
  ];

  void _addArea() {
    // TODO: navigate to area search / picker
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '제외 지역 설정'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -- Heading --
                  Text(
                    '제외된 지역 목록 ${_areas.length}',
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
                  for (int i = 0; i < _areas.length; i++) ...[
                    _AreaCard(
                      area: _areas[i],
                      onTap: () {
                        // TODO: edit area detail
                      },
                    ),
                    if (i < _areas.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
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
// Area card
// ---------------------------------------------------------------------------

class _AreaCard extends StatelessWidget {
  final _ExcludedArea area;
  final VoidCallback onTap;

  const _AreaCard({
    required this.area,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                color: _tagColor(area.tag).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                area.tag,
                style: TextStyle(
                  color: _tagColor(area.tag),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Address
            Expanded(
              child: Text(
                area.address,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
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

// ---------------------------------------------------------------------------
// Excluded area model
// ---------------------------------------------------------------------------

class _ExcludedArea {
  final String tag;
  final String address;

  const _ExcludedArea({
    required this.tag,
    required this.address,
  });
}
