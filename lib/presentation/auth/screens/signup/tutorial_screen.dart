import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_curve.dart';

class TutorialScreen extends StatefulWidget {
  final bool fromSignup;

  const TutorialScreen({super.key, this.fromSignup = false});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _introPages = [
    {'text': '한 번 마주치면 우연,', 'sub': ''},
    {'text': '두 번 마주치면 필연,', 'sub': ''},
    {'text': '세 번부터는 인연', 'sub': '스친 인연을, 이토로 잇다'},
  ];

  static const _featurePages = [
    {'icon': 'toggle', 'text': '인연 만나기 버튼을 누르면\n위치 정보가 활성화 되고,\n인연을 찾을 수 있어요.'},
    {'icon': 'tabs', 'text': '버튼을 눌러서\n당신의 인연, 필연, 우연을\n확인해보세요.'},
    {'icon': 'chat', 'text': '마음에 드는 인연을 찾아\nItto 버튼을 누르면\n메시지를 전송 할 수 있어요.'},
    {'icon': 'timer', 'text': '소중한 인연을\n놓치지 마세요!'},
  ];

  int get _totalPages => _introPages.length + _featurePages.length;

  IconData _getFeatureIcon(String key) {
    switch (key) {
      case 'toggle':
        return Icons.toggle_on_outlined;
      case 'tabs':
        return Icons.tab_outlined;
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'timer':
        return Icons.timer_outlined;
      default:
        return Icons.info_outline;
    }
  }

  void _close() {
    if (widget.fromSignup) {
      context.go('/home');
    } else {
      Navigator.of(context).pop();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _close();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIntroPage = _currentPage < _introPages.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Decorative curve background on intro pages
          if (isIntroPage)
            Positioned.fill(
              child: IttoCurve(
                opacity: 0.6,
                variant: _currentPage == 0
                    ? IttoCurveVariant.top
                    : IttoCurveVariant.both,
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                    child: GestureDetector(
                      onTap: _close,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x14FFFFFF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0x24FFFFFF)),
                        ),
                        child: const Text(
                          '건너뛰기',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalPages,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      if (index < _introPages.length) {
                        return _buildIntroPage(_introPages[index]);
                      } else {
                        return _buildFeaturePage(
                          _featurePages[index - _introPages.length],
                        );
                      }
                    },
                  ),
                ),
                _buildPageIndicator(),
                _buildNavButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroPage(Map<String, String> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Itto',
          style: GoogleFonts.notoSansKr(
            fontSize: 84,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -3,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 80),
        Text(
          page['text']!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFE8E8E8),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (page['sub']!.isNotEmpty) ...[
          const SizedBox(height: 80),
          Text(
            page['sub']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturePage(Map<String, String> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.pillGradient,
            boxShadow: const [
              BoxShadow(
                color: Color(0x40A78BFA),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            _getFeatureIcon(page['icon']!),
            size: 40,
            color: AppColors.pillText,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          page['text']!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalPages, (index) {
          final active = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 8 : 6,
            height: active ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? AppColors.accent
                  : AppColors.textSecondary.withValues(alpha: 0.4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavButtons() {
    final canGoBack = _currentPage > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: canGoBack ? _previousPage : null,
            child: Opacity(
              opacity: canGoBack ? 1.0 : 0.0,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Text(
                  '이전',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _nextPage,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.pillGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40A78BFA),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _currentPage < _totalPages - 1 ? '다음' : '완료',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pillText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
