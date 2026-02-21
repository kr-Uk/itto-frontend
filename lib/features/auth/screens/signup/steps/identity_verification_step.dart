import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';
import '../../../providers/signup_provider.dart';
import '../../../services/identity_service.dart';

class IdentityVerificationStep extends StatefulWidget {
  final VoidCallback onNext;

  const IdentityVerificationStep({super.key, required this.onNext});

  @override
  State<IdentityVerificationStep> createState() =>
      _IdentityVerificationStepState();
}

class _IdentityVerificationStepState extends State<IdentityVerificationStep> {
  bool _isLoading = false;
  String? _error;

  Future<void> _startVerification() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final identityService = context.read<IdentityService>();
      final result = await identityService.requestVerification();

      if (!mounted) return;

      // WebView 모달로 NICE 인증 페이지 열기
      final success = await _showWebView(result.authUrl);

      if (!mounted) return;

      if (success == true) {
        // 인증 결과 조회
        await _fetchStatus();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.userMessage);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '본인인증 요청 중 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _showWebView(String authUrl) async {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _IdentityWebView(
        authUrl: authUrl,
        onResult: (success) => Navigator.of(context).pop(success),
      ),
    );
  }

  Future<void> _fetchStatus() async {
    try {
      final identityService = context.read<IdentityService>();
      final status = await identityService.getVerificationStatus();

      if (!mounted) return;

      if (status.isSuccess) {
        context.read<SignupProvider>().setIdentityResult(
          name: status.name ?? '',
          phone: status.phoneNumber ?? '',
          gender: status.gender ?? '',
          birthDate: status.birthDate ?? '',
        );
        widget.onNext();
      } else {
        setState(() => _error = '본인인증에 실패했습니다. 다시 시도해주세요.');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.userMessage);
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
            '본인인증을\n진행해주세요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '안전한 서비스 이용을 위해 본인인증이 필요합니다.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // 안내 박스
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  icon: Icons.verified_user_outlined,
                  text: '중복 가입 방지를 위해 사용됩니다.',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.person_outline,
                  text: '성별과 생년월일이 자동으로 입력됩니다.',
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.lock_outline,
                  text: '개인정보는 안전하게 암호화 처리됩니다.',
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _error!,
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          const Spacer(),
          PurpleButton(
            text: _isLoading ? '처리 중...' : '본인인증하기',
            enabled: !_isLoading,
            onPressed: _startVerification,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityWebView extends StatefulWidget {
  final String authUrl;
  final void Function(bool success) onResult;

  const _IdentityWebView({
    required this.authUrl,
    required this.onResult,
  });

  @override
  State<_IdentityWebView> createState() => _IdentityWebViewState();
}

class _IdentityWebViewState extends State<_IdentityWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'IttoIdentity',
        onMessageReceived: (message) {
          _handleMessage(message.message);
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          // PASS 앱 등 외부 앱 URL 스킴 허용
          final url = request.url;
          if (url.startsWith('http://') || url.startsWith('https://')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final status = data['status'] as String?;
      widget.onResult(status == 'success');
    } catch (_) {
      widget.onResult(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 닫기 버튼
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () => widget.onResult(false),
            ),
          ),
          // WebView
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
