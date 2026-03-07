import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/purple_button.dart';

class HobbyStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const HobbyStep({super.key, required this.onNext});

  @override
  ConsumerState<HobbyStep> createState() => _HobbyStepState();
}

class _HobbyStepState extends ConsumerState<HobbyStep> {
  final Set<int> _selectedHobbies = {};

  static const int _minSelection = 1;
  static const int _maxSelection = 3;

  bool get _isValid => _selectedHobbies.length >= _minSelection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signupChangeNotifierProvider).fetchHobbies();
    });
  }

  void _toggleHobby(int hobbyId) {
    setState(() {
      if (_selectedHobbies.contains(hobbyId)) {
        _selectedHobbies.remove(hobbyId);
      } else if (_selectedHobbies.length < _maxSelection) {
        _selectedHobbies.add(hobbyId);
      }
    });
  }

  void _handleNext() {
    final provider = ref.read(signupChangeNotifierProvider);
    provider.hobbyIds = _selectedHobbies.toList();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) { final provider = ref.watch(signupChangeNotifierProvider);
        final hobbies = provider.hobbies;
        final isLoading = provider.isLoading;

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
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : hobbies.isEmpty
                    ? Center(
                        child: Text(
                          '취미 데이터를 불러올 수 없습니다.\n잠시 후 다시 시도해 주세요.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: hobbies.map((hobby) {
                            final isSelected = _selectedHobbies.contains(
                              hobby.id,
                            );
                            return GestureDetector(
                              onTap: () => _toggleHobby(hobby.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(
                                          alpha: 0.15,
                                        )
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
                                  hobby.name,
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
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
                enabled: _isValid && !isLoading,
                onPressed: _isValid && !isLoading ? _handleNext : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
