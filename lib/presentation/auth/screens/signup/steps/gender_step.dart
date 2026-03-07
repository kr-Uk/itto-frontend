import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/purple_button.dart';

class GenderStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const GenderStep({super.key, required this.onNext});

  @override
  ConsumerState<GenderStep> createState() => _GenderStepState();
}

class _GenderStepState extends ConsumerState<GenderStep> {
  String? _selectedGender;
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    final provider = ref.read(signupChangeNotifierProvider);
    if (provider.identityVerified && provider.verifiedGender != null) {
      _selectedGender = provider.verifiedGender == 'FEMALE' ? 'female' : 'male';
      _isReadOnly = true;
    }
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
            _isReadOnly
                ? '본인인증으로 확인된 성별입니다.'
                : '성별은 추후 변경이 불가능해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          _GenderOption(
            label: '여성',
            isSelected: _selectedGender == 'female',
            onTap: _isReadOnly
                ? () {}
                : () => setState(() => _selectedGender = 'female'),
          ),
          const SizedBox(height: 16),
          _GenderOption(
            label: '남성',
            isSelected: _selectedGender == 'male',
            onTap: _isReadOnly
                ? () {}
                : () => setState(() => _selectedGender = 'male'),
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            enabled: _selectedGender != null,
            onPressed: () {
              ref.read(signupChangeNotifierProvider).gender =
                  _selectedGender == 'female' ? 'FEMALE' : 'MALE';
              widget.onNext();
            },
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
