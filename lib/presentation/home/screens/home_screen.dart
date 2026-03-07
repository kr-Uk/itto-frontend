import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/presentation/home/screens/tabs/inyeon_tab.dart';
import 'package:itto/presentation/home/screens/tabs/pilyeon_tab.dart';
import 'package:itto/presentation/home/screens/tabs/uyeon_tab.dart';
import 'package:itto/presentation/home/screens/tabs/past_inyeon_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabLabels = ['인연', '필연', '우연', '지난인연'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(relationshipChangeNotifierProvider).loadAllTabs();
      ref.read(shopChangeNotifierProvider).loadBalance();

      // 백그라운드 위치 플러그인 초기화
      // (이전에 매칭이 활성화된 상태였으면 자동으로 추적 재개됨)
      ref.read(locationChangeNotifierProvider).initBackgroundGeolocation();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  InyeonTab(),
                  PilyeonTab(),
                  UyeonTab(),
                  PastInyeonTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "Itto" logo text
          const Text(
            'Itto',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          // Toggle switch with label
          Consumer(builder: (context, ref, _) { final locationProvider = ref.watch(locationChangeNotifierProvider);
              final isEnabled = locationProvider.isMatchingEnabled;
              return Row(
                children: [
                  Text(
                    '인연 만나기',
                    style: TextStyle(
                      color: isEnabled
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 28,
                    child: Switch(
                      value: isEnabled,
                      onChanged: (value) async {
                        final success = await locationProvider.toggleMatching(
                          value,
                        );
                        if (!success && context.mounted) {
                          SnackBarUtils.showError(
                            context,
                            locationProvider.error ?? '위치 설정에 실패했습니다',
                          );
                        }
                      },
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(
                        alpha: 0.3,
                      ),
                      inactiveThumbColor: AppColors.textTertiary,
                      inactiveTrackColor: AppColors.surfaceLight,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          // Tab items
          Expanded(
            child: Row(
              children: List.generate(_tabLabels.length, (index) {
                final isSelected = _tabController.index == index;
                return GestureDetector(
                  onTap: () {
                    _tabController.animateTo(index);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < _tabLabels.length - 1 ? 24 : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          _tabLabels[index],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Dot indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // Heart icon + knot count (tap to navigate to knot management)
          Consumer(builder: (context, ref, _) { final shopProvider = ref.watch(shopChangeNotifierProvider);
              return GestureDetector(
                key: const Key('knot_display'),
                onTap: () => context.push('/settings/currency'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${shopProvider.knots}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
