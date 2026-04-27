import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/purple_button.dart';

class BirthdayStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const BirthdayStep({super.key, required this.onNext});

  @override
  ConsumerState<BirthdayStep> createState() => _BirthdayStepState();
}

class _BirthdayStepState extends ConsumerState<BirthdayStep> {
  DateTime? _selectedDate;
  bool _isReadOnly = false;

  @override
  void initState() {
    super.initState();
    final provider = ref.read(signupChangeNotifierProvider);
    if (provider.identityVerified && provider.verifiedBirthDate != null) {
      _selectedDate = DateTime.parse(provider.verifiedBirthDate!);
      _isReadOnly = true;
    }
  }

  bool get _isValid => _selectedDate != null;

  DateTime get _lastSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year - 14, now.month, now.day);
  }

  Future<void> _showDatePickerDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? _lastSelectableDate,
      firstDate: DateTime(1930, 1, 1),
      lastDate: _lastSelectableDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.pillText,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) return '';
    final d = _selectedDate!;
    return '${d.year} . ${d.month.toString().padLeft(2, '0')} . ${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            '만 14세 이상이신가요?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _isReadOnly
                ? '본인인증으로 확인된 생년월일입니다.'
                : 'Itto는 만 14세 이상의 사용자만 이용할 수 있어요.\n나이를 확인해 주세요.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),
          GestureDetector(
            onTap: _isReadOnly ? null : _showDatePickerDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: _isValid
                    ? Border.all(color: AppColors.accent, width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '생년월일',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _isValid ? _formattedDate : '생년월일을 선택해 주세요',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: _isValid
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            enabled: _isValid,
            onPressed: () {
              final d = _selectedDate!;
              final formatted =
                  '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
              ref.read(signupChangeNotifierProvider).birthDate = formatted;
              widget.onNext();
            },
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
