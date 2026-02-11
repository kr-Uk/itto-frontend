import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';

class NicknameStep extends StatefulWidget {
  final VoidCallback onNext;

  const NicknameStep({super.key, required this.onNext});

  @override
  State<NicknameStep> createState() => _NicknameStepState();
}

class _NicknameStepState extends State<NicknameStep> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _errorText = '';
  bool _isValid = false;

  static const int _maxLength = 14;

  // Characters not allowed: special characters except Korean, English, numbers
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
      error = '닉네임은 최대 ${_maxLength}자까지 가능해요.';
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
          const SizedBox(height: 40),
          Text(
            '환영합니다!\n먼저 닉네임을\n만들어 볼까요?',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLength: _maxLength,
            style: GoogleFonts.notoSansKr(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(_maxLength),
            ],
            decoration: InputDecoration(
              hintText: '닉네임을 입력해주세요',
              hintStyle: GoogleFonts.notoSansKr(
                fontSize: 16,
                color: AppColors.textTertiary,
              ),
              counterText: '',
              suffixText: '${_controller.text.length}/$_maxLength',
              suffixStyle: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText.isNotEmpty
                      ? AppColors.error
                      : AppColors.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _errorText.isNotEmpty
                      ? AppColors.error
                      : AppColors.primary,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (_errorText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _errorText,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: AppColors.error,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '* 한글, 영문, 숫자 조합 가능 (최대 ${_maxLength}자)',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
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
