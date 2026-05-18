import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:itto/core/theme/app_theme.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/core/router/app_router.dart';
import 'package:itto/core/services/fcm_service.dart';

class IttoApp extends StatefulWidget {
  const IttoApp({super.key});

  @override
  State<IttoApp> createState() => _IttoAppState();
}

class _IttoAppState extends State<IttoApp> {
  OverlayEntry? _notificationOverlay;

  @override
  void initState() {
    super.initState();
    FcmService.instance.onForegroundMessageCallback = _showNotificationBanner;
    FcmService.instance.onDeepLinkCallback = _handleDeepLink;

    // Terminated 상태에서 알림 탭으로 앱 열린 경우 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FcmService.instance.handleInitialMessage();
    });
  }

  @override
  void dispose() {
    FcmService.instance.onForegroundMessageCallback = null;
    FcmService.instance.onDeepLinkCallback = null;
    _notificationOverlay?.remove();
    super.dispose();
  }

  void _handleDeepLink(String deepLink) {
    appRouter.push(deepLink);
  }

  void _showNotificationBanner(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    // 이전 배너 제거
    _notificationOverlay?.remove();
    _notificationOverlay = null;

    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _notificationOverlay = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        title: notification.title ?? '',
        body: notification.body ?? '',
        deepLink: message.data['deepLink'] as String?,
        onDismiss: () {
          _notificationOverlay?.remove();
          _notificationOverlay = null;
        },
      ),
    );

    overlay.insert(_notificationOverlay!);

    // 4초 후 자동 제거
    Future.delayed(const Duration(seconds: 4), () {
      if (_notificationOverlay != null) {
        _notificationOverlay?.remove();
        _notificationOverlay = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Itto',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR')],
    );
  }
}

/// Foreground 푸시 수신 시 화면 상단에 표시되는 알림 배너
class _InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final String? deepLink;
  final VoidCallback onDismiss;

  const _InAppNotificationBanner({
    required this.title,
    required this.body,
    this.deepLink,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onDismiss();
    if (widget.deepLink != null && widget.deepLink!.isNotEmpty) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        GoRouter.of(context).push(widget.deepLink!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < 0) {
              widget.onDismiss();
            }
          },
          child: SafeArea(
            bottom: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.body.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.body,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textTertiary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
