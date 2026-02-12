import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

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
    {
      'icon': 'toggle',
      'text': '인연 만나기 버튼을 누르면\n위치 정보가 활성화 되고,\n인연을 찾을 수 있어요.',
    },
    {
      'icon': 'tabs',
      'text': '버튼을 눌러서\n당신의 인연, 필연, 우연을\n확인해보세요.',
    },
    {
      'icon': 'chat',
      'text': '마음에 드는 인연을 찾아\nItto 버튼을 누르면\n메시지를 전송 할 수 있어요.',
    },
    {
      'icon': 'timer',
      'text': '24시간이 지나면\n프로필이 사라지니\n유의하세요!',
    },
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

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textTertiary),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '건너뛰기',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
    );
  }

  Widget _buildIntroPage(Map<String, String> page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Itto',
          style: GoogleFonts.notoSansKr(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 60),
        Text(
          page['text']!,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        if (page['sub']!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            page['sub']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: AppColors.textTertiary,
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
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
          child: Icon(
            _getFeatureIcon(page['icon']!),
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          page['text']!,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansKr(
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
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 8 : 6,
            height: _currentPage == index ? 8 : 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? AppColors.primary
                  : AppColors.textTertiary.withValues(alpha: 0.4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentPage > 0 ? _previousPage : null,
            child: Text(
              '이전',
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                color: _currentPage > 0
                    ? AppColors.textSecondary
                    : Colors.transparent,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(
              _currentPage < _totalPages - 1 ? '다음' : '완료',
              style: GoogleFonts.notoSansKr(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
