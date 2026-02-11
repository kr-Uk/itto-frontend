import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class BirthdayStep extends StatefulWidget {
  final VoidCallback onNext;

  const BirthdayStep({super.key, required this.onNext});

  @override
  State<BirthdayStep> createState() => _BirthdayStepState();
}

class _BirthdayStepState extends State<BirthdayStep> {
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;

  bool get _isValid =>
      _selectedYear != null &&
      _selectedMonth != null &&
      _selectedDay != null;

  int get _currentYear => DateTime.now().year;

  List<int> get _years => List.generate(
        _currentYear - 1930 + 1,
        (i) => _currentYear - i,
      );

  List<int> get _months => List.generate(12, (i) => i + 1);

  List<int> get _days {
    if (_selectedYear == null || _selectedMonth == null) {
      return List.generate(31, (i) => i + 1);
    }
    final daysInMonth =
        DateTime(_selectedYear!, _selectedMonth! + 1, 0).day;
    return List.generate(daysInMonth, (i) => i + 1);
  }

  void _showPicker({
    required String title,
    required List<int> items,
    required int? currentValue,
    required String suffix,
    required ValueChanged<int> onSelected,
  }) {
    int tempIndex =
        currentValue != null ? items.indexOf(currentValue) : 0;
    if (tempIndex < 0) tempIndex = 0;

    final scrollController =
        FixedExtentScrollController(initialItem: tempIndex);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '취소',
                        style: GoogleFonts.notoSansKr(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onSelected(items[tempIndex]);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '확인',
                        style: GoogleFonts.notoSansKr(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.divider, height: 1),
              Expanded(
                child: CupertinoPicker(
                  scrollController: scrollController,
                  magnification: 1.2,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 40,
                  selectionOverlay: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  onSelectedItemChanged: (index) {
                    tempIndex = index;
                  },
                  children: items.map((item) {
                    return Center(
                      child: Text(
                        '$item$suffix',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
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
            '생년월일은 추후 변경이 불가능해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _DateChip(
                  label: _selectedYear != null
                      ? '${_selectedYear}년'
                      : 'YYYY',
                  isSelected: _selectedYear != null,
                  onTap: () => _showPicker(
                    title: '출생 연도',
                    items: _years,
                    currentValue: _selectedYear,
                    suffix: '년',
                    onSelected: (value) {
                      setState(() {
                        _selectedYear = value;
                        // Re-validate day if month is selected
                        if (_selectedDay != null &&
                            _selectedMonth != null) {
                          final maxDay = DateTime(value, _selectedMonth! + 1, 0).day;
                          if (_selectedDay! > maxDay) {
                            _selectedDay = maxDay;
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _DateChip(
                  label: _selectedMonth != null
                      ? '${_selectedMonth}월'
                      : 'MM',
                  isSelected: _selectedMonth != null,
                  onTap: () => _showPicker(
                    title: '출생 월',
                    items: _months,
                    currentValue: _selectedMonth,
                    suffix: '월',
                    onSelected: (value) {
                      setState(() {
                        _selectedMonth = value;
                        // Re-validate day
                        if (_selectedDay != null &&
                            _selectedYear != null) {
                          final maxDay = DateTime(_selectedYear!, value + 1, 0).day;
                          if (_selectedDay! > maxDay) {
                            _selectedDay = maxDay;
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _DateChip(
                  label:
                      _selectedDay != null ? '${_selectedDay}일' : 'DD',
                  isSelected: _selectedDay != null,
                  onTap: () => _showPicker(
                    title: '출생 일',
                    items: _days,
                    currentValue: _selectedDay,
                    suffix: '일',
                    onSelected: (value) {
                      setState(() => _selectedDay = value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
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

class _DateChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
