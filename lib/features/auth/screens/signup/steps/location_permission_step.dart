import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/purple_button.dart';
import '../../../../../shared/utils/snackbar_utils.dart';
import '../../../providers/signup_provider.dart';

class LocationPermissionStep extends StatefulWidget {
  final VoidCallback onNext;

  const LocationPermissionStep({super.key, required this.onNext});

  @override
  State<LocationPermissionStep> createState() => _LocationPermissionStepState();
}

class _LocationPermissionStepState extends State<LocationPermissionStep> {
  bool _agreed = false;

  Future<void> _handleNext() async {
    // OS 위치 권한 요청
    final locationStatus = await Permission.location.request();
    if (!mounted) return;

    if (locationStatus.isDenied || locationStatus.isPermanentlyDenied) {
      SnackBarUtils.showError(
        context,
        '위치 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
      );
      if (locationStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      return;
    }

    // 백그라운드 위치 권한 요청 (Android)
    final bgStatus = await Permission.locationAlways.request();
    if (!mounted) return;

    if (bgStatus.isDenied || bgStatus.isPermanentlyDenied) {
      // 백그라운드 권한은 선택 사항으로 처리 (포그라운드만으로도 동작 가능)
      debugPrint('[LocationPermission] 백그라운드 위치 권한 거부됨 - 포그라운드만 사용');
    }

    // 약관 저장
    final provider = context.read<SignupProvider>();
    final success = await provider.saveTerms();

    if (!mounted) return;

    if (success) {
      widget.onNext();
    } else {
      SnackBarUtils.showError(
        context,
        provider.error ?? '약관 저장에 실패했습니다',
      );
    }
  }

  void _showDetailSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '위치기반서비스 이용약관',
                style: GoogleFonts.notoSansKr(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Itto는 사용자의 위치 정보를 기반으로 주변의 인연을 찾아드립니다. '
                '위치 정보는 서비스 이용 중에만 수집되며, 다른 사용자에게 정확한 위치가 공개되지 않습니다. '
                '수집된 위치 정보는 서비스 제공 목적으로만 사용되며, 이용 목적 달성 후 즉시 파기됩니다.',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PurpleButton(
                  text: '확인',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 8),
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
            '인연을 찾기 위해서는\n위치기반서비스 동의가\n필요해요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _showDetailSheet,
            child: Row(
              children: [
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '자세히 보기',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              setState(() {
                _agreed = !_agreed;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _agreed ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: _agreed ? AppColors.primary : AppColors.textTertiary,
                      width: 2,
                    ),
                  ),
                  child: _agreed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  '위치기반서비스 이용에 동의합니다.',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Consumer<SignupProvider>(
            builder: (context, provider, child) {
              return PurpleButton(
                text: provider.isLoading ? '저장 중...' : '다음',
                enabled: _agreed && !provider.isLoading,
                onPressed: _agreed && !provider.isLoading ? _handleNext : null,
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
