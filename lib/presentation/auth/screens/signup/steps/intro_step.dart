import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/purple_button.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';

class IntroStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const IntroStep({super.key, required this.onNext});

  @override
  ConsumerState<IntroStep> createState() => _IntroStepState();
}

class _IntroStepState extends ConsumerState<IntroStep> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLength = 24;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final provider = ref.read(signupChangeNotifierProvider);
    provider.introduction = _controller.text.trim();

    final success = await provider.saveProfile();

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      widget.onNext();
    } else {
      SnackBarUtils.showError(context, provider.error ?? '프로필 저장에 실패했습니다');
    }
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
            '한 줄 소개를 적어주세요.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '스쳐가는 인연들에게 보여질 첫인상이에요.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Underline-style input matching prototype
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0x2EFFFFFF), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: _maxLength,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: '나는 멋쟁이',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                      counterText: '',
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Text(
                  '${_controller.text.length}/$_maxLength',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                  ),
                )
              : PurpleButton(text: '다음', enabled: true, onPressed: _handleNext),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
