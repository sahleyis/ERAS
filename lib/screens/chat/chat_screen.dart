import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message_model.dart';

/// Real-time chat screen for victim-responder communication.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = ChatService();

  String? _emergencyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _emergencyId =
        ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _emergencyId == null) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    _chatService.sendTextMessage(
      emergencyId: _emergencyId!,
      senderId: user.uid,
      text: text,
    );

    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: kAnimationMedium,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Chat'),
        actions: [
          // Share location button
          IconButton(
            onPressed: () {
              if (user == null || _emergencyId == null) return;
              // Send location as message
              _chatService.sendSystemMessage(
                emergencyId: _emergencyId!,
                text: '📍 Location shared',
              );
            },
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'Share Location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _emergencyId == null
                ? const Center(
                    child: Text('No active emergency'),
                  )
                : StreamBuilder<List<ChatMessage>>(
                    stream:
                        _chatService.streamMessages(_emergencyId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: ErasTheme.textTertiary,
                              ),
                              const SizedBox(height: ErasTheme.spacingMd),
                              Text(
                                'No messages yet',
                                style: ErasTheme.titleMedium.copyWith(
                                  color: ErasTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: ErasTheme.spacingXs),
                              Text(
                                'Send a message to communicate\nwith your responder',
                                style: ErasTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      // Mark messages as read
                      if (user != null) {
                        _chatService.markAsRead(
                          emergencyId: _emergencyId!,
                          currentUserId: user.uid,
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(
                          ErasTheme.spacingMd,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMine =
                              user != null && msg.isMine(user.uid);
                          final isSystem =
                              msg.type == MessageType.system;

                          if (isSystem) {
                            return _SystemMessage(text: msg.text);
                          }

                          return _ChatBubble(
                            message: msg,
                            isMine: isMine,
                          );
                        },
                      );
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: ErasTheme.spacingMd,
              right: ErasTheme.spacingSm,
              top: ErasTheme.spacingSm,
              bottom: MediaQuery.of(context).padding.bottom +
                  ErasTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: ErasTheme.surfaceDark,
              border: const Border(
                top: BorderSide(color: ErasTheme.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: ErasTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: ErasTheme.bodyMedium.copyWith(
                        color: ErasTheme.textTertiary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ErasTheme.borderRadiusFull,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: ErasTheme.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: ErasTheme.spacingMd,
                        vertical: ErasTheme.spacingSm,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: ErasTheme.medicalBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;

  const _ChatBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? ErasTheme.medicalBlue
              : ErasTheme.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMine ? const Radius.circular(16) : Radius.zero,
            bottomRight:
                isMine ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: ErasTheme.bodyLarge.copyWith(
                color: isMine
                    ? Colors.white
                    : ErasTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.timeLabel,
              style: ErasTheme.labelSmall.copyWith(
                color: isMine
                    ? Colors.white.withOpacity(0.6)
                    : ErasTheme.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final String text;

  const _SystemMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: ErasTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(
            ErasTheme.borderRadiusFull,
          ),
        ),
        child: Text(
          text,
          style: ErasTheme.labelSmall.copyWith(
            color: ErasTheme.textTertiary,
          ),
        ),
      ),
    );
  }
}
