import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat message model for victim-responder communication
/// during an active emergency.
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final MessageType type;
  final DateTime? timestamp;
  final bool read;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.timestamp,
    this.read = false,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'text'),
        orElse: () => MessageType.text,
      ),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
      read: data['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type.name,
      'timestamp': FieldValue.serverTimestamp(),
      'read': read,
    };
  }

  /// Whether this message was sent by the given user.
  bool isMine(String currentUserId) => senderId == currentUserId;

  /// Formatted time string (HH:mm).
  String get timeLabel {
    if (timestamp == null) return '';
    final h = timestamp!.hour.toString().padLeft(2, '0');
    final m = timestamp!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

enum MessageType {
  text,
  image,
  system,
  location,
}
