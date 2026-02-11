import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class GenderStep extends StatefulWidget {
  final VoidCallback onNext;

  const GenderStep({super.key, required this.onNext});

  @override
  State<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends State<GenderStep> {
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            '본인의 성별을\n선택해주세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '성별은 추후 변경이 불가능해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          _GenderOption(
            label: '여성',
            isSelected: _selectedGender == 'female',
            onTap: () => setState(() => _selectedGender = 'female'),
          ),
          const SizedBox(height: 16),
          _GenderOption(
            label: '남성',
            isSelected: _selectedGender == 'male',
            onTap: () => setState(() => _selectedGender = 'male'),
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            enabled: _selectedGender != null,
            onPressed: widget.onNext,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
