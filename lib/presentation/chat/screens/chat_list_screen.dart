import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:intl/intl.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/widgets/itto_app_bar.dart';
import 'package:itto/domain/chat/entities/chat_room.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatRooms();
    });
  }

  void _loadChatRooms() {
    final profileProvider = ref.read(profileChangeNotifierProvider);
    final chatProvider = ref.read(chatChangeNotifierProvider);

    final currentUserId = profileProvider.myProfile?.userId;
    if (currentUserId == null) return;

    chatProvider.loadChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const IttoAppBar(title: '인연 채팅', showBack: false),
      body: Consumer(builder: (context, ref, _) { final chatProvider = ref.watch(chatChangeNotifierProvider);
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
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            itemCount: chatProvider.chatRooms.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.divider,
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final chatRoom = chatProvider.chatRooms[index];
              final currentUserId =
                  ref.read(profileChangeNotifierProvider).myProfile?.userId ?? 0;
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

  LinearGradient _getAvatarGradient(String name) {
    const swatches = <List<Color>>[
      [Color(0xFF7A6450), Color(0xFF3A3026)],
      [Color(0xFF3D2A26), Color(0xFF1A1010)],
      [Color(0xFF4A3A30), Color(0xFF221A14)],
      [Color(0xFF5A4030), Color(0xFF2C1E16)],
      [Color(0xFF3A2A30), Color(0xFF1A1218)],
    ];
    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    final pair = swatches[hash % swatches.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: pair,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = chatRoom.getOtherUserName(currentUserId);

    return InkWell(
      onTap: () {
        context.push(
          '/chat/${chatRoom.id}?name=${Uri.encodeComponent(userName)}',
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar (62×62 rounded-square)
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: _getAvatarGradient(userName),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.2, -0.3),
                          radius: 0.55,
                          colors: [
                            const Color(0x26FFDCC8),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0] : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chatRoom.lastMessage ?? '메시지가 없습니다',
                    style: const TextStyle(
                      color: Color(0xFFB8B8B8),
                      fontSize: 13,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time + gradient unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(chatRoom.lastMessageAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (chatRoom.unreadCount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(minWidth: 28),
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: AppColors.pillGradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      chatRoom.unreadCount > 999
                          ? '999'
                          : chatRoom.unreadCount.toString(),
                      style: const TextStyle(
                        color: Color(0xFF3A2A52),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
