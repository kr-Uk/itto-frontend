import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class HobbyStep extends StatefulWidget {
  final VoidCallback onNext;

  const HobbyStep({super.key, required this.onNext});

  @override
  State<HobbyStep> createState() => _HobbyStepState();
}

class _HobbyStepState extends State<HobbyStep> {
  final Set<String> _selectedHobbies = {};

  static const List<String> _hobbies = [
    '영화', '헬스', '독서', '뜨개질', '사주/타로', '인테리어',
    '요리', '식물', '댄스', '웹툰', '산책', '드라마',
    '멍 때리기', '청소', '여행', '일기', '주식', '사진',
    '메이크업', '애니', '카페', 'K-pop', '연기', 'J-pop',
    '골프', '축구', '커피', '배드민턴', '게임', '그림',
  ];

  static const int _minSelection = 1;
  static const int _maxSelection = 5;

  bool get _isValid => _selectedHobbies.length >= _minSelection;

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else if (_selectedHobbies.length < _maxSelection) {
        _selectedHobbies.add(hobby);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            '당신의 취미는\n무엇인가요?',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '최소 $_minSelection개 최대 $_maxSelection개 선택해 주세요. 다른 사람들이 볼 수 있어요!',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _hobbies.map((hobby) {
                  final isSelected = _selectedHobbies.contains(hobby);
                  return GestureDetector(
                    onTap: () => _toggleHobby(hobby),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.divider,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        hobby,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PurpleButton(
            text: '다음',
            enabled: _isValid,
            onPressed: widget.onNext,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
