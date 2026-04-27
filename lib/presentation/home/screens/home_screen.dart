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
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Itto title + subtitle
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itto',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  ': 스친 인연을, 이토로 잇다',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Right side: location toggle + label
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Consumer(
              builder: (context, ref, _) {
                final locationProvider = ref.watch(
                  locationChangeNotifierProvider,
                );
                final isEnabled = locationProvider.isMatchingEnabled;
                return Column(
                  children: [
                    _IttoSwitch(
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
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '인연 만나기',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      padding: const EdgeInsets.only(bottom: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x14FFFFFF), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(_tabLabels.length, (index) {
                final isSelected = _tabController.index == index;
                return GestureDetector(
                  onTap: () => _tabController.animateTo(index),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < _tabLabels.length - 1 ? 32 : 0,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Text(
                          _tabLabels[index],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: -8,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          // Heart icon + knot count
          Consumer(
            builder: (context, ref, _) {
              final shopProvider = ref.watch(shopChangeNotifierProvider);
              return GestureDetector(
                key: const Key('knot_display'),
                onTap: () => context.push('/settings/currency'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.pillGradient.createShader(bounds),
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

/// 프로토타입 디자인의 그라데이션 토글 (켜져 있을 때 peach→purple).
class _IttoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _IttoSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: value ? AppColors.pillGradient : null,
          color: value ? null : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
