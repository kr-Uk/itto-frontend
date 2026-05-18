import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/auth/screens/signup/steps/location_permission_step.dart';
import 'package:itto/presentation/auth/screens/signup/steps/nickname_step.dart';
import 'package:itto/presentation/auth/screens/signup/steps/birthday_step.dart';
import 'package:itto/presentation/auth/screens/signup/steps/gender_step.dart';
import 'package:itto/presentation/auth/screens/signup/steps/hobby_step.dart';
import 'package:itto/presentation/auth/screens/signup/steps/intro_step.dart';
import 'package:itto/presentation/auth/screens/signup/steps/signup_photo_step.dart';
import 'package:itto/presentation/auth/screens/signup/steps/welcome_step.dart';

class SignupFlowScreen extends StatefulWidget {
  const SignupFlowScreen({super.key});

  @override
  State<SignupFlowScreen> createState() => _SignupFlowScreenState();
}

class _SignupFlowScreenState extends State<SignupFlowScreen> {
  late final PageController _pageController;
  int _currentStep = 0;

  static const int _totalSteps = 8;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: _goToPreviousStep,
          ),
          centerTitle: true,
          title: Text(
            'Itto',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          _ProgressBar(progress: progress),
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                LocationPermissionStep(onNext: _goToNextStep), // 1. 위치 동의
                NicknameStep(onNext: _goToNextStep), // 2. 닉네임
                BirthdayStep(onNext: _goToNextStep), // 3. 생년월일
                GenderStep(onNext: _goToNextStep), // 4. 성별
                HobbyStep(onNext: _goToNextStep), // 5. 취미 선택
                IntroStep(onNext: _goToNextStep), // 6. 자기소개
                SignupPhotoStep(onNext: _goToNextStep), // 7. 프로필 사진 (최대 1장)
                const WelcomeStep(), // 8. 환영
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 3,
      color: AppColors.surfaceLight,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: const BoxDecoration(gradient: AppColors.buttonGradient),
        ),
      ),
    );
  }
}
