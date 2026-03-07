import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return DateTime(now.year - 19, now.month, now.day);
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
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
    return '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일';
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
            '생년월일을\n입력해주세요.',
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
                ? '본인인증으로 확인된 생년월일입니다.'
                : '생년월일은 추후 변경이 불가능해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _isReadOnly ? null : _showDatePickerDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isValid ? AppColors.primary : AppColors.divider,
                  width: _isValid ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: _isValid
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isValid ? _formattedDate : '생년월일을 선택해 주세요',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 15,
                      fontWeight: _isValid ? FontWeight.w500 : FontWeight.w400,
                      color: _isValid
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
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
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
