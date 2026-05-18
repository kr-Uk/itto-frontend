import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            '성별을 알려주세요.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '등록 후 변경은 어려워요.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _GenderOption(
            label: '여성',
            isSelected: _selectedGender == 'female',
            onTap: () => setState(() => _selectedGender = 'female'),
          ),
          const SizedBox(height: 12),
          _GenderOption(
            label: '남성',
            isSelected: _selectedGender == 'male',
            onTap: () => setState(() => _selectedGender = 'male'),
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
          const SizedBox(height: 36),
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
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.18)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
