import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/snackbar_utils.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../../shared/widgets/itto_dialog.dart';
import '../../relationship/providers/relationship_provider.dart';
import '../models/notification_models.dart';
import '../providers/notification_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<NotificationProvider>();
      if (!provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  String _formatRelativeTime(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inSeconds < 60) return '방금 전';
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      if (diff.inDays < 7) return '${diff.inDays}일 전';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}개월 전';
      return '${(diff.inDays / 365).floor()}년 전';
    } catch (_) {
      return createdAt;
    }
  }

  void _dismissAll() {
    context.read<NotificationProvider>().deleteAllNotifications();
  }

  /// 날짜 문자열을 기반으로 그룹 라벨을 반환
  String _getDateGroupLabel(String createdAt) {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final diff = today.difference(date).inDays;

      if (diff == 0) return '오늘';
      if (diff == 1) return '어제';
      if (diff < 7) return '이번 주';
      if (diff < 30) return '이번 달';
      return '이전';
    } catch (_) {
      return '이전';
    }
  }

  /// 알림 목록을 날짜 그룹별로 분류
  List<_NotificationGroup> _groupByDate(List<NotificationItem> notifications) {
    final groups = <String, List<NotificationItem>>{};
    final groupOrder = <String>[];

    for (final notification in notifications) {
      final label = _getDateGroupLabel(notification.createdAt);
      if (!groups.containsKey(label)) {
        groups[label] = [];
        groupOrder.add(label);
      }
      groups[label]!.add(notification);
    }

    return groupOrder
        .map((label) => _NotificationGroup(label: label, items: groups[label]!))
        .toList();
  }

  Future<void> _showInyeonRequestDialog(NotificationItem notification) async {
    if (notification.referenceId == null) {
      SnackBarUtils.showError(context, '요청 정보를 찾을 수 없습니다.');
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => IttoDialog(
        icon: const Icon(Icons.favorite, color: AppColors.primary, size: 36),
        title: "'${notification.title}'\n수락하시겠습니까?",
        subtitle: '*인연이 되면 채팅이 가능합니다.',
        cancelText: '거절하기',
        confirmText: '수락하기',
      ),
    );

    if (!mounted) return;

    final relationshipProvider = context.read<RelationshipProvider>();

    if (accepted == true) {
      final success = await relationshipProvider.acceptRequest(
        notification.referenceId!,
      );
      if (!mounted) return;
      if (success) {
        SnackBarUtils.showSuccess(context, '인연 요청을 수락했습니다!');
      } else {
        SnackBarUtils.showError(
          context,
          relationshipProvider.error ?? '인연 수락에 실패했습니다.',
        );
      }
    } else if (accepted == false) {
      final success = await relationshipProvider.rejectRequest(
        notification.referenceId!,
      );
      if (!mounted) return;
      if (success) {
        SnackBarUtils.showSuccess(context, '인연 요청을 거절했습니다.');
      } else {
        SnackBarUtils.showError(
          context,
          relationshipProvider.error ?? '인연 거절에 실패했습니다.',
        );
      }
    }
  }

  Future<void> _showRestoreRequestDialog(NotificationItem notification) async {
    if (notification.referenceId == null) {
      SnackBarUtils.showError(context, '요청 정보를 찾을 수 없습니다.');
      return;
    }

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => IttoDialog(
        icon: const Icon(Icons.refresh, color: AppColors.primary, size: 36),
        title: "'${notification.title}'님이\n다시 만나기를 요청했습니다",
        subtitle: '다시 만나시겠습니까?',
        cancelText: '거절하기',
        confirmText: '수락하기',
      ),
    );

    if (!mounted) return;

    final relationshipProvider = context.read<RelationshipProvider>();

    if (accepted == true) {
      final success = await relationshipProvider.restoreAccept(
        notification.referenceId!,
      );
      if (!mounted) return;
      if (success) {
        SnackBarUtils.showSuccess(context, '다시 만나기를 수락했습니다!');
      } else {
        SnackBarUtils.showError(
          context,
          relationshipProvider.error ?? '수락에 실패했습니다.',
        );
      }
    } else if (accepted == false) {
      final success = await relationshipProvider.restoreReject(
        notification.referenceId!,
      );
      if (!mounted) return;
      if (success) {
        SnackBarUtils.showSuccess(context, '다시 만나기를 거절했습니다.');
      } else {
        SnackBarUtils.showError(
          context,
          relationshipProvider.error ?? '거절에 실패했습니다.',
        );
      }
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    // Mark as read
    if (!notification.isRead) {
      context.read<NotificationProvider>().markAsRead([notification.id]);
    }

    // Handle navigation based on type
    if (notification.type == 'INYEON_REQUEST') {
      _showInyeonRequestDialog(notification);
      return;
    }

    if (notification.type == 'RESTORE_REQUEST') {
      _showRestoreRequestDialog(notification);
      return;
    }

    // Navigate to deepLink if available
    if (notification.deepLink != null && notification.deepLink!.isNotEmpty) {
      context.push(notification.deepLink!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '알림', showBack: false),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading &&
              notificationProvider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          final groups = _groupByDate(notifications);

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              for (int gi = 0; gi < groups.length; gi++) ...[
                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        groups[gi].label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (gi == 0)
                        GestureDetector(
                          onTap: _dismissAll,
                          child: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Notification items in this group
                ...groups[gi].items.map(
                  (notification) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _NotificationCard(
                      notification: notification,
                      formattedTime: _formatRelativeTime(
                        notification.createdAt,
                      ),
                      onTap: () => _onNotificationTap(notification),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none,
            color: AppColors.textTertiary,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            '알림이 없습니다',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final String formattedTime;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.formattedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.cardBackground
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon / Avatar
            _buildLeading(),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message.isNotEmpty
                        ? notification.message
                        : notification.title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    final type = notification.type;

    // INYEON_REQUEST, INYEON_ACCEPTED, INYEON_REJECTED, RESTORE_REQUEST → heart icon
    if (type == 'INYEON_REQUEST' ||
        type == 'INYEON_ACCEPTED' ||
        type == 'INYEON_REJECTED' ||
        type == 'RESTORE_REQUEST') {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.favorite, color: AppColors.primary, size: 20),
      );
    }

    // MESSAGE → avatar style with first letter
    if (type == 'MESSAGE') {
      final firstLetter = notification.title.isNotEmpty
          ? notification.title[0]
          : '?';
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            firstLetter,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    // Others → notification bell icon
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.notifications,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }
}

/// 날짜별 알림 그룹
class _NotificationGroup {
  final String label;
  final List<NotificationItem> items;

  const _NotificationGroup({required this.label, required this.items});
}
