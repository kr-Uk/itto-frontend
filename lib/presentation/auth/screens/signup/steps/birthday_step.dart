import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  static const int _minAge = 19;

  static final DateFormat _displayFormat = DateFormat('yyyy년 M월 d일');
  static final DateFormat _storageFormat = DateFormat('yyyy-MM-dd');

  DateTime get _maxSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year - _minAge, now.month, now.day);
  }

  Future<void> _openPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(_maxSelectableDate.year - 6, 1, 1),
      firstDate: DateTime(1940, 1, 1),
      lastDate: _maxSelectableDate,
      helpText: '생년월일 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
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

  @override
  Widget build(BuildContext context) {
    final hasDate = _selectedDate != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            '생년월일을\n알려주세요.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '만 $_minAge세 이상만 가입할 수 있어요.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 36),
          const Text(
            '생년월일',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _openPicker,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0x2EFFFFFF), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      hasDate
                          ? _displayFormat.format(_selectedDate!)
                          : '날짜 선택',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: hasDate
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '허위 정보 입력 시 이용이 제한될 수 있어요.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            enabled: hasDate,
            onPressed: () {
              ref.read(signupChangeNotifierProvider).birthDate =
                  _storageFormat.format(_selectedDate!);
              widget.onNext();
            },
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
