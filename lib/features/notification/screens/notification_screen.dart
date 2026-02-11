import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../../shared/widgets/itto_dialog.dart';

enum _NotificationType { chatRequest, message, connection }

class _NotificationItem {
  final String id;
  final _NotificationType type;
  final String title;
  final String? senderName;
  final String time;
  final Color? avatarColor;

  const _NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.senderName,
    required this.time,
    this.avatarColor,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotificationItem> _notifications = [
    const _NotificationItem(
      id: '1',
      type: _NotificationType.chatRequest,
      title: "'수수'님이 대화를 요청했어요! 수락하시겠습니까?",
      senderName: '수수',
      time: '방금 전',
    ),
    _NotificationItem(
      id: '2',
      type: _NotificationType.message,
      title: '치맛이: ㅎㅎ 포켓몬 닮았당',
      senderName: '치맛이',
      time: '5분 전',
      avatarColor: const Color(0xFF94F6D6),
    ),
    const _NotificationItem(
      id: '3',
      type: _NotificationType.connection,
      title: '새로운 인연 신청이 있어요! 확인해 보세요',
      time: '30분 전',
    ),
    _NotificationItem(
      id: '4',
      type: _NotificationType.message,
      title: '이종원: 아 맞다 내일 약속 있었지?',
      senderName: '이종원',
      time: '1시간 전',
      avatarColor: const Color(0xFF7BB3FF),
    ),
    const _NotificationItem(
      id: '5',
      type: _NotificationType.chatRequest,
      title: "'민지'님이 대화를 요청했어요! 수락하시겠습니까?",
      senderName: '민지',
      time: '2시간 전',
    ),
    const _NotificationItem(
      id: '6',
      type: _NotificationType.connection,
      title: '새로운 인연 신청이 있어요! 확인해 보세요',
      time: '3시간 전',
    ),
  ];

  void _dismissAll() {
    setState(() {
      _notifications.clear();
    });
  }

  void _showRequestDialog(_NotificationItem notification) {
    showDialog<bool>(
      context: context,
      builder: (context) => IttoDialog(
        icon: const Icon(
          Icons.favorite,
          color: AppColors.primary,
          size: 36,
        ),
        title: "'${notification.senderName}'님이 인연을 요청하셨습니다.\n수락하시겠습니까?",
        subtitle: '*인연이 되면 채팅이 가능합니다.',
        cancelText: '거절하기',
        confirmText: '수락하기',
      ),
    ).then((accepted) {
      if (accepted == true && mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${notification.senderName}'님과 인연이 되었습니다!"),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else if (accepted == false && mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
      }
    });
  }

  void _onNotificationTap(_NotificationItem notification) {
    switch (notification.type) {
      case _NotificationType.chatRequest:
        _showRequestDialog(notification);
        break;
      case _NotificationType.message:
        // TODO: Navigate to chat room
        break;
      case _NotificationType.connection:
        _showRequestDialog(notification);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(
        title: '알림',
        showBack: false,
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '오늘',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

                // Notification items
                ..._notifications.map(
                  (notification) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _NotificationCard(
                      notification: notification,
                      onTap: () => _onNotificationTap(notification),
                    ),
                  ),
                ),
              ],
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
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
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
                    notification.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.time,
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
    switch (notification.type) {
      case _NotificationType.chatRequest:
      case _NotificationType.connection:
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite,
            color: AppColors.primary,
            size: 20,
          ),
        );
      case _NotificationType.message:
        final color = notification.avatarColor ?? AppColors.primary;
        return Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              notification.senderName?[0] ?? '?',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
    }
  }
}
