import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../providers/demo_provider.dart';

/// A simple in-memory message for demo/non-emergency chat.
class _ChatMsg {
  final String text;
  final bool isMe;
  final DateTime time;

  _ChatMsg({required this.text, required this.isMe, DateTime? time})
      : time = time ?? DateTime.now();

  String get timeLabel {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Simulated auto-replies for demo mode.
const _autoReplies = [
  "Hello! How can I help you today?",
  "I understand your concern. Can you describe your symptoms?",
  "That sounds manageable. Let me give you some advice.",
  "For now, try to stay hydrated and rest. Monitor your temperature.",
  "If symptoms worsen, I recommend visiting a clinic or triggering an SOS alert.",
  "Is there anything else I can help with?",
];

/// Non-emergency messaging chat screen.
/// Works entirely in-memory for demo mode.
/// For real mode, uses Firestore chat collection.
class MessagingChatScreen extends ConsumerStatefulWidget {
  const MessagingChatScreen({super.key});

  @override
  ConsumerState<MessagingChatScreen> createState() =>
      _MessagingChatScreenState();
}

class _MessagingChatScreenState extends ConsumerState<MessagingChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMsg> _messages = [];
  int _replyIndex = 0;
  String _responderName = 'Responder';
  String _specialization = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _responderName = args['responderName'] as String? ?? 'Responder';
      _specialization = args['specialization'] as String? ?? '';
    }

    // Add initial system message
    if (_messages.isEmpty) {
      _messages.add(_ChatMsg(
        text: 'Connected with $_responderName',
        isMe: false,
        time: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMsg(text: text, isMe: true));
    });

    _controller.clear();
    _scrollToBottom();

    // Auto-reply in demo mode
    final isDemo = ref.read(isDemoModeProvider);
    if (isDemo && _replyIndex < _autoReplies.length) {
      final delay = Duration(milliseconds: 800 + (_replyIndex * 200));
      Timer(delay, () {
        if (!mounted) return;
        setState(() {
          _messages.add(_ChatMsg(
            text: _autoReplies[_replyIndex],
            isMe: false,
          ));
          _replyIndex++;
        });
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = ref.watch(isDemoModeProvider);

    return Scaffold(
      backgroundColor: ErasTheme.backgroundDark,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: ErasTheme.medicalBlue.withOpacity(0.2),
              child: Text(
                _responderName.split(' ').map((p) => p[0]).take(2).join(),
                style: const TextStyle(
                  color: ErasTheme.medicalBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _responderName,
                    style: ErasTheme.titleMedium.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_specialization.isNotEmpty)
                    Text(
                      _specialization,
                      style: ErasTheme.labelSmall.copyWith(
                        color: ErasTheme.medicalBlue,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Non-emergency badge
          Container(
            margin: const EdgeInsets.only(right: ErasTheme.spacingSm),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ErasTheme.successGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(ErasTheme.borderRadiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: ErasTheme.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Non-Emergency',
                  style: ErasTheme.labelSmall.copyWith(
                    color: ErasTheme.successGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Demo banner
          if (isDemo)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: ErasTheme.spacingMd,
                vertical: 6,
              ),
              color: ErasTheme.warningAmber.withOpacity(0.1),
              child: Text(
                'DEMO - Simulated conversation with auto-replies',
                style: ErasTheme.labelSmall.copyWith(
                  color: ErasTheme.warningAmber,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Disclaimer
          Container(
            margin: const EdgeInsets.all(ErasTheme.spacingSm),
            padding: const EdgeInsets.symmetric(
              horizontal: ErasTheme.spacingMd,
              vertical: ErasTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: ErasTheme.surfaceCard,
              borderRadius: BorderRadius.circular(ErasTheme.borderRadiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: ErasTheme.textTertiary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is a non-emergency consultation. For emergencies, use the SOS button.',
                    style: ErasTheme.labelSmall.copyWith(
                      color: ErasTheme.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: ErasTheme.textTertiary),
                        const SizedBox(height: ErasTheme.spacingSm),
                        Text(
                          'Start a conversation',
                          style: ErasTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(ErasTheme.spacingMd),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _MessageBubble(message: msg);
                    },
                  ),
          ),

          // Quick suggestion chips
          if (_messages.length <= 2)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: ErasTheme.spacingMd,
                ),
                children: [
                  _SuggestionChip(
                    label: 'I have a headache',
                    onTap: () {
                      _controller.text = 'I have a persistent headache. What should I do?';
                      _sendMessage();
                    },
                  ),
                  _SuggestionChip(
                    label: 'Minor cut/wound',
                    onTap: () {
                      _controller.text = 'I have a minor cut. How should I treat it?';
                      _sendMessage();
                    },
                  ),
                  _SuggestionChip(
                    label: 'Fever advice',
                    onTap: () {
                      _controller.text = 'I have a fever of 38.5C. What do you recommend?';
                      _sendMessage();
                    },
                  ),
                ],
              ),
            ),

          if (_messages.length <= 2) const SizedBox(height: 8),

          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: ErasTheme.spacingMd,
              right: ErasTheme.spacingSm,
              top: ErasTheme.spacingSm,
              bottom: MediaQuery.of(context).padding.bottom + ErasTheme.spacingSm,
            ),
            decoration: const BoxDecoration(
              color: ErasTheme.surfaceDark,
              border: Border(
                top: BorderSide(color: ErasTheme.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: ErasTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
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

class _MessageBubble extends StatelessWidget {
  final _ChatMsg message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isMe
              ? ErasTheme.medicalBlue
              : ErasTheme.surfaceCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                message.isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight:
                message.isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: ErasTheme.bodyLarge.copyWith(
                color: message.isMe ? Colors.white : ErasTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.timeLabel,
              style: ErasTheme.labelSmall.copyWith(
                color: message.isMe
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

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: ErasTheme.labelSmall.copyWith(
            color: ErasTheme.medicalBlue,
          ),
        ),
        onPressed: onTap,
        backgroundColor: ErasTheme.medicalBlue.withOpacity(0.1),
        side: BorderSide(
          color: ErasTheme.medicalBlue.withOpacity(0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ErasTheme.borderRadiusFull),
        ),
      ),
    );
  }
}
