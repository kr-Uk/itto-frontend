import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itto/core/di/providers.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itto/core/theme/app_colors.dart';
import 'package:itto/presentation/common/utils/snackbar_utils.dart';
import 'package:itto/presentation/common/widgets/itto_dialog.dart';
import 'package:itto/domain/block/entities/report_request.dart';
import 'package:itto/domain/chat/entities/chat_message.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String userName;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.userName,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _showAttachmentMenu = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUserId =
          ref.read(profileChangeNotifierProvider).myProfile?.userId ?? 0;
      final chatProvider = ref.read(chatChangeNotifierProvider);

      // Firestore에 채팅방이 없으면 생성
      await chatProvider.ensureChatRoomExists(
        chatRoomId: widget.chatId,
        participantIds: [currentUserId],
      );

      chatProvider.subscribeToChatMessages(
        widget.chatId,
        currentUserId,
      );
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = ref.read(profileChangeNotifierProvider).myProfile?.userId;
    if (currentUserId == null) return;

    _textController.clear();
    setState(() => _showAttachmentMenu = false);

    final success = await ref.read(chatChangeNotifierProvider).sendMessage(
      chatRoomId: widget.chatId,
      senderId: currentUserId,
      text: text,
    );

    if (!success && mounted) {
      SnackBarUtils.showError(context, '메시지 전송에 실패했습니다');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleAttachmentMenu() {
    setState(() {
      _showAttachmentMenu = !_showAttachmentMenu;
    });
  }

  Future<void> _pickAndSendImage() async {
    // Show dialog to choose camera or gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '사진 선택',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text(
                '카메라',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text(
                '갤러리',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null || !mounted) return;

      final chatProvider = ref.read(chatChangeNotifierProvider);
      final currentUserId = ref.read(profileChangeNotifierProvider).myProfile?.userId;
      if (currentUserId == null) return;

      setState(() => _showAttachmentMenu = false);

      // 로딩 표시
      if (mounted) {
        SnackBarUtils.showInfo(context, '사진 업로드 중...');
      }

      final success = await chatProvider.sendImageMessage(
        chatRoomId: widget.chatId,
        senderId: currentUserId,
        filePath: image.path,
      );

      if (!success && mounted) {
        SnackBarUtils.showError(context, '사진 전송에 실패했습니다');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, '사진을 선택하는데 실패했습니다: $e');
      }
    }
  }

  int? _getOtherUserId() {
    final relationships = ref.read(relationshipChangeNotifierProvider).getByStatus(
      'INYEON',
    );
    final rel = relationships
        .where((r) => r.chatRoomId == widget.chatId)
        .firstOrNull;
    return rel?.otherUser.userId;
  }

  Future<void> _handleBlock() async {
    final otherUserId = _getOtherUserId();
    if (otherUserId == null) {
      SnackBarUtils.showError(context, '상대 정보를 찾을 수 없습니다');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => IttoDialog(
        title: "'${widget.userName}'님을 차단하시겠습니까?",
        subtitle: '차단하면 서로 매칭되지 않습니다.',
        confirmText: '차단',
        cancelText: '취소',
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await ref.read(blockChangeNotifierProvider).blockUser(otherUserId);
    if (!mounted) return;
    if (success) {
      SnackBarUtils.showSuccess(context, '차단되었습니다');
      context.pop();
    } else {
      SnackBarUtils.showError(context, '차단에 실패했습니다');
    }
  }

  Future<void> _handleReport() async {
    final otherUserId = _getOtherUserId();
    if (otherUserId == null) {
      SnackBarUtils.showError(context, '상대 정보를 찾을 수 없습니다');
      return;
    }

    final category = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text(
          '신고 사유 선택',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        children:
            {
                  'INAPPROPRIATE_PHOTO': '부적절한 사진',
                  'HARASSMENT': '괴롭힘',
                  'SPAM': '스팸/광고',
                  'PROFANITY': '욕설/혐오 발언',
                  'OTHER': '기타',
                }.entries
                .map(
                  (entry) => SimpleDialogOption(
                    onPressed: () => Navigator.of(ctx).pop(entry.key),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
    if (category == null || !mounted) return;

    final success = await ref.read(blockChangeNotifierProvider).report(
      ReportRequest(
        targetUserId: otherUserId,
        category: category,
        targetType: 'CHAT',
        chatRoomId: widget.chatId,
      ),
    );
    if (!mounted) return;
    if (success) {
      SnackBarUtils.showSuccess(context, '신고가 접수되었습니다');
    } else {
      SnackBarUtils.showError(context, '신고에 실패했습니다');
    }
  }

  void _navigateToMap() {
    final relationships = ref.read(relationshipChangeNotifierProvider).getByStatus(
      'INYEON',
    );
    final rel = relationships
        .where((r) => r.chatRoomId == widget.chatId)
        .firstOrNull;
    if (rel != null) {
      context.push('/encounter/${rel.relationshipId}');
    } else {
      SnackBarUtils.showError(context, '만남 위치 정보를 찾을 수 없습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        ref.read(profileChangeNotifierProvider).myProfile?.userId ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.userName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.location_on_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: _navigateToMap,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'block') _handleBlock();
              if (value == 'report') _handleReport();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text(
                      '차단하기',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, size: 20, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      '신고하기',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                if (_showAttachmentMenu) {
                  setState(() => _showAttachmentMenu = false);
                }
              },
              child: Consumer(builder: (context, ref, _) { final chatProvider = ref.watch(chatChangeNotifierProvider);
                  if (chatProvider.isLoading &&
                      chatProvider.currentMessages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = chatProvider.currentMessages;

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        '메시지가 없습니다\n첫 메시지를 보내보세요!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSent = message.senderId == currentUserId;

                      final isFirst = index == 0;
                      final isNewGroup =
                          isFirst ||
                          messages[index - 1].senderId != message.senderId ||
                          _isDifferentTimeGroup(
                            messages[index - 1].createdAt,
                            message.createdAt,
                          );
                      final isLastInGroup =
                          index == messages.length - 1 ||
                          messages[index + 1].senderId != message.senderId ||
                          _isDifferentTimeGroup(
                            message.createdAt,
                            messages[index + 1].createdAt,
                          );

                      // 1:1 채팅: readBy에 본인 외 다른 사람이 포함되면 읽음
                      final isRead = isSent && message.readBy.length >= 2;

                      return _MessageBubble(
                        message: message,
                        userName: widget.userName,
                        isSent: isSent,
                        isRead: isRead,
                        showAvatar: isNewGroup && !isSent,
                        showTimestamp: isLastInGroup,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Attachment menu
          if (_showAttachmentMenu) _buildAttachmentMenu(),

          // Bottom input area
          _buildInputArea(),
        ],
      ),
    );
  }

  bool _isDifferentTimeGroup(DateTime time1, DateTime time2) {
    return time2.difference(time1).inMinutes > 1;
  }

  Widget _buildAttachmentMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _AttachmentButton(
            icon: Icons.camera_alt_outlined,
            label: '사진',
            onTap: _pickAndSendImage,
          ),
          const SizedBox(width: 32),
          _AttachmentButton(
            icon: Icons.location_on_outlined,
            label: '인연 위치 확인',
            onTap: _navigateToMap,
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // "+" button
          GestureDetector(
            onTap: _toggleAttachmentMenu,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: _showAttachmentMenu
                    ? AppColors.primary
                    : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showAttachmentMenu ? Icons.close : Icons.add,
                color: _showAttachmentMenu
                    ? Colors.white
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _textController,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요',
                  hintStyle: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 15,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onTap: () {
                  if (_showAttachmentMenu) {
                    setState(() => _showAttachmentMenu = false);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String userName;
  final bool isSent;
  final bool isRead;
  final bool showAvatar;
  final bool showTimestamp;

  const _MessageBubble({
    required this.message,
    required this.userName,
    required this.isSent,
    this.isRead = false,
    required this.showAvatar,
    required this.showTimestamp,
  });

  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('a h:mm', 'ko_KR').format(dateTime);
  }

  Widget _buildMessageContent() {
    if (message.type == 'image' && message.text.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: message.text,
          width: 200,
          fit: BoxFit.cover,
          placeholder: (context, url) => const SizedBox(
            width: 200,
            height: 150,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => const SizedBox(
            width: 200,
            height: 150,
            child: Center(
              child: Icon(Icons.broken_image, color: AppColors.textTertiary),
            ),
          ),
        ),
      );
    } else {
      // Regular text message
      return Text(
        message.text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 12 : 2,
        bottom: showTimestamp ? 4 : 2,
      ),
      child: Column(
        crossAxisAlignment: isSent
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isSent
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar for received messages
              if (!isSent && showAvatar)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userName.isNotEmpty ? userName[0] : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (!isSent)
                const SizedBox(width: 44), // Space for missing avatar
              // Message bubble
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSent
                        ? AppColors.chatBubbleSent
                        : AppColors.chatBubbleReceived,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isSent ? 16 : 4),
                      bottomRight: Radius.circular(isSent ? 4 : 16),
                    ),
                  ),
                  child: _buildMessageContent(),
                ),
              ),
            ],
          ),

          // Timestamp + Read indicator
          if (showTimestamp)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isSent ? 0 : 44,
                right: isSent ? 0 : 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isSent
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (isSent && isRead) ...[
                    const Text(
                      '읽음',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
