import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/itto_app_bar.dart';
import '../../profile/providers/profile_provider.dart';
import '../../relationship/providers/relationship_provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_models.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatRooms();
    });
  }

  void _loadChatRooms() {
    final profileProvider = context.read<ProfileProvider>();
    final relationshipProvider = context.read<RelationshipProvider>();
    final chatProvider = context.read<ChatProvider>();

    final currentUserId = profileProvider.myProfile?.userId;
    if (currentUserId == null) return;

    final inyeonRelationships = relationshipProvider.getByStatus('INYEON');
    final chatRoomIdToName = <String, String>{};

    for (final rel in inyeonRelationships) {
      if (rel.chatRoomId != null) {
        chatRoomIdToName[rel.chatRoomId!] = rel.otherUser.nickname;
      }
    }

    chatProvider.subscribeToChatRooms(currentUserId, chatRoomIdToName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '인연 채팅', showBack: false),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.chatRooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.chatRooms.isEmpty) {
            return const Center(
              child: Text(
                '아직 채팅이 없습니다',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatProvider.chatRooms.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.divider,
              height: 1,
              indent: 84,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final chatRoom = chatProvider.chatRooms[index];
              final currentUserId =
                  context.read<ProfileProvider>().myProfile?.userId ?? 0;
              return _ChatListTile(
                chatRoom: chatRoom,
                currentUserId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final ChatRoom chatRoom;
  final int currentUserId;

  const _ChatListTile({required this.chatRoom, required this.currentUserId});

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('a h:mm', 'ko_KR').format(dateTime);
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('M/d').format(dateTime);
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFE8A0BF),
      const Color(0xFF7BB3FF),
      const Color(0xFFB794F6),
      const Color(0xFFF6B794),
      const Color(0xFF94F6D6),
      const Color(0xFFF694B8),
      const Color(0xFF94C4F6),
    ];
    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final userName = chatRoom.getOtherUserName(currentUserId);
    final avatarColor = _getAvatarColor(userName);

    return InkWell(
      onTap: () {
        context.push(
          '/chat/${chatRoom.id}?name=${Uri.encodeComponent(userName)}',
        );
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
                color: avatarColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0] : '?',
                  style: TextStyle(
                    color: avatarColor,
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
                    userName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.lastMessage ?? '메시지가 없습니다',
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
                  _formatTime(chatRoom.lastMessageAt),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                if (chatRoom.unreadCount > 0)
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
                      chatRoom.unreadCount.toString(),
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
