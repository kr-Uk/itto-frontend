import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/purple_button.dart';

class NicknameStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const NicknameStep({super.key, required this.onNext});

  @override
  ConsumerState<NicknameStep> createState() => _NicknameStepState();
}

class _NicknameStepState extends ConsumerState<NicknameStep> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _errorText = '';
  bool _isValid = false;

  static const int _maxLength = 12;

  static final _validPattern = RegExp(r'^[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ]+$');

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validate);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _validate() {
    final text = _controller.text;
    String error = '';
    bool valid = false;

    if (text.isEmpty) {
      error = '';
      valid = false;
    } else if (text.length > _maxLength) {
      error = '닉네임은 최대 $_maxLength자까지 가능해요.';
      valid = false;
    } else if (!_validPattern.hasMatch(text)) {
      error = '특수문자 및 공백은 사용할 수 없어요.';
      valid = false;
    } else if (text.length < 2) {
      error = '닉네임은 최소 2자 이상이어야 해요.';
      valid = false;
    } else {
      error = '';
      valid = true;
    }

    setState(() {
      _errorText = error;
      _isValid = valid;
    });
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
            'Itto에서 사용할\n닉네임을 알려주세요.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),
          const Text(
            '닉네임',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          // Underline-style input matching prototype
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: _errorText.isNotEmpty
                      ? AppColors.error
                      : const Color(0x2EFFFFFF),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLength: _maxLength,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_maxLength),
                    ],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: '닉네임',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                      counterText: '',
                      filled: false,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
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
          if (_errorText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _errorText,
              style: const TextStyle(fontSize: 13, color: AppColors.error),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            '닉네임은 한글, 영문, 숫자 포함 12자 이내로 작성해 주세요.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const Spacer(),
          PurpleButton(
            text: '다음',
            enabled: _isValid,
            onPressed: () {
              ref.read(signupChangeNotifierProvider).nickname = _controller.text
                  .trim();
              widget.onNext();
            },
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}
