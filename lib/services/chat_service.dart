import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/chat_message_model.dart';

/// Real-time chat service for victim-responder communication
/// during an active emergency.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send a text message.
  Future<void> sendTextMessage({
    required String emergencyId,
    required String senderId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: '',
      senderId: senderId,
      text: text,
      type: MessageType.text,
    );

    await _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .add(message.toFirestore());
  }

  /// Send a system message (e.g., "Responder is on the way").
  Future<void> sendSystemMessage({
    required String emergencyId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: '',
      senderId: 'system',
      text: text,
      type: MessageType.system,
    );

    await _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .add(message.toFirestore());
  }

  /// Send a location-share message.
  Future<void> sendLocationMessage({
    required String emergencyId,
    required String senderId,
    required double latitude,
    required double longitude,
  }) async {
    final message = ChatMessage(
      id: '',
      senderId: senderId,
      text: '$latitude,$longitude',
      type: MessageType.location,
    );

    await _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .add(message.toFirestore());
  }

  /// Stream all messages for an emergency in real-time.
  Stream<List<ChatMessage>> streamMessages(String emergencyId) {
    return _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// Get unread message count for a user.
  Stream<int> streamUnreadCount({
    required String emergencyId,
    required String currentUserId,
  }) {
    return _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Mark all messages from the other party as read.
  Future<void> markAsRead({
    required String emergencyId,
    required String currentUserId,
  }) async {
    final unread = await _firestore
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
