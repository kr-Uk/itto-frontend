import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';

class _ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final Color avatarColor;

  const _ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.avatarColor,
  });
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static final List<_ChatItem> _mockChats = [
    _ChatItem(
      id: '1',
      name: '이선희',
      lastMessage: '오늘 날씨 너무 좋다~ 같이 산책할래요?',
      time: '오후 3:42',
      unreadCount: 2,
      avatarColor: const Color(0xFFE8A0BF),
    ),
    _ChatItem(
      id: '2',
      name: '이종원',
      lastMessage: '아 맞다 내일 약속 있었지? 몇 시에 만날까요',
      time: '오후 2:15',
      unreadCount: 0,
      avatarColor: const Color(0xFF7BB3FF),
    ),
    _ChatItem(
      id: '3',
      name: '오시온',
      lastMessage: 'ㅋㅋㅋ 진짜 웃기다',
      time: '오후 1:30',
      unreadCount: 5,
      avatarColor: const Color(0xFFB794F6),
    ),
    _ChatItem(
      id: '4',
      name: '사쿠야',
      lastMessage: '사진 보내줄게 잠깐만!',
      time: '오전 11:20',
      unreadCount: 1,
      avatarColor: const Color(0xFFF6B794),
    ),
    _ChatItem(
      id: '5',
      name: '김치만두',
      lastMessage: 'ㅎㅎ 포켓몬 닮았당',
      time: '오전 9:45',
      unreadCount: 0,
      avatarColor: const Color(0xFF94F6D6),
    ),
    _ChatItem(
      id: '6',
      name: '박만두',
      lastMessage: '네~ 알겠습니다 감사해요!',
      time: '어제',
      unreadCount: 0,
      avatarColor: const Color(0xFFF694B8),
    ),
    _ChatItem(
      id: '7',
      name: '시준희',
      lastMessage: '혹시 그 카페 어디에 있어요? 위치 좀 알려주세요',
      time: '어제',
      unreadCount: 3,
      avatarColor: const Color(0xFF94C4F6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(
        title: '인연 채팅',
        showBack: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _mockChats.length,
        separatorBuilder: (context, index) => const Divider(
          color: AppColors.divider,
          height: 1,
          indent: 84,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final chat = _mockChats[index];
          return _ChatListTile(chat: chat);
        },
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final _ChatItem chat;

  const _ChatListTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/chat/${chat.id}?name=${Uri.encodeComponent(chat.name)}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: chat.avatarColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  chat.name[0],
                  style: TextStyle(
                    color: chat.avatarColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    chat.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 4),
                Text(
                  chat.time,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.unreadBadge,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
