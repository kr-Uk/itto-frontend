import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../relationship/providers/relationship_provider.dart';
import '../../location/providers/location_provider.dart';
import '../../shop/providers/shop_provider.dart';
import 'tabs/inyeon_tab.dart';
import 'tabs/pilyeon_tab.dart';
import 'tabs/uyeon_tab.dart';
import 'tabs/past_inyeon_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
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
      context.read<RelationshipProvider>().loadAllTabs();
      context.read<ShopProvider>().loadBalance();

      // 백그라운드 위치 플러그인 초기화
      // (이전에 매칭이 활성화된 상태였으면 자동으로 추적 재개됨)
      context.read<LocationProvider>().initBackgroundGeolocation();
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
          Consumer<LocationProvider>(
            builder: (context, locationProvider, _) {
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
                      onChanged: (value) {
                        locationProvider.toggleMatching(value);
                      },
                      activeThumbColor: AppColors.primary,
                      activeTrackColor:
                          AppColors.primary.withValues(alpha: 0.3),
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
          // Heart icon + knot count
          Consumer<ShopProvider>(
            builder: (context, shopProvider, _) {
              return Row(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
