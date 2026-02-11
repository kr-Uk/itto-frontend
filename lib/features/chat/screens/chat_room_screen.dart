import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum _MessageType { sent, received }

class _ChatMessage {
  final String text;
  final _MessageType type;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.type,
    required this.time,
  });
}

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String userName;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.userName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showAttachmentMenu = false;

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: '안녕하세요! 반갑습니다 :)',
      type: _MessageType.received,
      time: '오후 2:30',
    ),
    const _ChatMessage(
      text: '혹시 아까 카페에서 본 분 맞으시죠?',
      type: _MessageType.received,
      time: '오후 2:30',
    ),
    const _ChatMessage(
      text: '네 맞아요! 안녕하세요~',
      type: _MessageType.sent,
      time: '오후 2:32',
    ),
    const _ChatMessage(
      text: '저도 이토 쓰시는 줄 몰랐어요 ㅎㅎ',
      type: _MessageType.sent,
      time: '오후 2:32',
    ),
    const _ChatMessage(
      text: 'ㅋㅋ 저도요! 혹시 이 근처 자주 오세요?',
      type: _MessageType.received,
      time: '오후 2:35',
    ),
    const _ChatMessage(
      text: '네 거의 매일 와요. 커피가 맛있어서요',
      type: _MessageType.sent,
      time: '오후 2:36',
    ),
    const _ChatMessage(
      text: '오 저도! 아메리카노 좋아하세요?',
      type: _MessageType.received,
      time: '오후 2:38',
    ),
    const _ChatMessage(
      text: '라떼 파인데 아메리카노도 좋아해요',
      type: _MessageType.sent,
      time: '오후 2:39',
    ),
    const _ChatMessage(
      text: '다음에 같이 커피 한잔 해요!',
      type: _MessageType.received,
      time: '오후 2:40',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        type: _MessageType.sent,
        time: '오후 3:00',
      ));
      _textController.clear();
      _showAttachmentMenu = false;
    });

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

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              // TODO: Navigate to location view
            },
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isFirst = index == 0;
                  final isNewGroup = isFirst ||
                      _messages[index - 1].type != message.type ||
                      _messages[index - 1].time != message.time;
                  final isLastInGroup = index == _messages.length - 1 ||
                      _messages[index + 1].type != message.type ||
                      _messages[index + 1].time != message.time;

                  return _MessageBubble(
                    message: message,
                    userName: widget.userName,
                    showAvatar: isNewGroup && message.type == _MessageType.received,
                    showTimestamp: isLastInGroup,
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

  Widget _buildAttachmentMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _AttachmentButton(
            icon: Icons.camera_alt_outlined,
            label: '사진',
            onTap: () {
              // TODO: Open camera/gallery
            },
          ),
          const SizedBox(width: 32),
          _AttachmentButton(
            icon: Icons.location_on_outlined,
            label: '인연 위치 확인',
            onTap: () {
              // TODO: Open location check
            },
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
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
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
  final _ChatMessage message;
  final String userName;
  final bool showAvatar;
  final bool showTimestamp;

  const _MessageBubble({
    required this.message,
    required this.userName,
    required this.showAvatar,
    required this.showTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isSent = message.type == _MessageType.sent;

    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 12 : 2,
        bottom: showTimestamp ? 4 : 2,
      ),
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                      userName[0],
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
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Timestamp
          if (showTimestamp)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isSent ? 0 : 44,
                right: isSent ? 0 : 0,
              ),
              child: Text(
                message.time,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
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
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 24,
            ),
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
