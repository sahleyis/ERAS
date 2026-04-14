import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import '../models/emergency_model.dart';
import '../models/chat_message_model.dart';

/// Firestore CRUD operations for all collections.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Users ─────────────────────────────────────────────────

  /// Get a user by UID.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(kUsersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Stream a user's data in real-time.
  Stream<UserModel?> streamUser(String uid) {
    return _db
        .collection(kUsersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Update user profile fields.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(kUsersCollection).doc(uid).update(data);
  }

  /// Update medical profile.
  Future<void> updateMedicalProfile(
    String uid,
    MedicalProfile profile,
  ) async {
    await _db.collection(kUsersCollection).doc(uid).update({
      'medicalProfile': profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update responder profile.
  Future<void> updateResponderProfile(
    String uid,
    ResponderProfile profile,
  ) async {
    await _db.collection(kUsersCollection).doc(uid).update({
      'responderProfile': profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Emergencies ───────────────────────────────────────────

  /// Create a new emergency document.
  Future<String> createEmergency(EmergencyModel emergency) async {
    final docRef = await _db
        .collection(kEmergenciesCollection)
        .add(emergency.toFirestore());
    return docRef.id;
  }

  /// Get an emergency by ID.
  Future<EmergencyModel?> getEmergency(String id) async {
    final doc =
        await _db.collection(kEmergenciesCollection).doc(id).get();
    if (!doc.exists) return null;
    return EmergencyModel.fromFirestore(doc);
  }

  /// Stream an emergency document in real-time.
  Stream<EmergencyModel?> streamEmergency(String id) {
    return _db
        .collection(kEmergenciesCollection)
        .doc(id)
        .snapshots()
        .map((doc) =>
            doc.exists ? EmergencyModel.fromFirestore(doc) : null);
  }

  /// Update emergency fields.
  Future<void> updateEmergency(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection(kEmergenciesCollection).doc(id).update(data);
  }

  /// Get active emergencies for a victim.
  Stream<List<EmergencyModel>> streamVictimEmergencies(String victimId) {
    return _db
        .collection(kEmergenciesCollection)
        .where('victimId', isEqualTo: victimId)
        .where('status', whereIn: ['searching', 'matched', 'inProgress'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EmergencyModel.fromFirestore(doc))
            .toList());
  }

  /// Get incoming alerts for a responder (emergencies they've been notified about).
  Stream<List<EmergencyModel>> streamResponderAlerts(String responderId) {
    return _db
        .collection(kEmergenciesCollection)
        .where('status', isEqualTo: 'searching')
        .where('notifiedResponders', arrayContains: responderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EmergencyModel.fromFirestore(doc))
            .toList());
  }

  /// Accept an emergency as a responder.
  Future<bool> acceptEmergency({
    required String emergencyId,
    required String responderId,
    required String responderName,
  }) async {
    // Use a transaction to prevent race conditions
    return _db.runTransaction<bool>((transaction) async {
      final docRef =
          _db.collection(kEmergenciesCollection).doc(emergencyId);
      final doc = await transaction.get(docRef);

      if (!doc.exists) return false;

      final status = doc.data()?['status'] as String?;
      if (status != 'searching') {
        // Already accepted by another responder
        return false;
      }

      transaction.update(docRef, {
        'status': 'matched',
        'responderId': responderId,
        'responderName': responderName,
        'matchedAt': FieldValue.serverTimestamp(),
      });

      return true;
    });
  }

  /// Decline an emergency alert.
  Future<void> declineEmergency({
    required String emergencyId,
    required String responderId,
  }) async {
    await _db.collection(kEmergenciesCollection).doc(emergencyId).update({
      'declinedResponders': FieldValue.arrayUnion([responderId]),
    });
  }

  /// Resolve an emergency.
  Future<void> resolveEmergency(String id) async {
    await _db.collection(kEmergenciesCollection).doc(id).update({
      'status': 'resolved',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Cancel an emergency.
  Future<void> cancelEmergency(String id) async {
    await _db.collection(kEmergenciesCollection).doc(id).update({
      'status': 'cancelled',
    });
  }

  // ─── Responder Locations ───────────────────────────────────

  /// Update responder's active status and location.
  Future<void> updateResponderLocation({
    required String responderId,
    required bool isActive,
    required Map<String, dynamic> position,
    String? fcmToken,
  }) async {
    final data = <String, dynamic>{
      'userId': responderId,
      'isActive': isActive,
      'position': position,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
    if (fcmToken != null) data['fcmToken'] = fcmToken;

    await _db
        .collection(kResponderLocationsCollection)
        .doc(responderId)
        .set(data, SetOptions(merge: true));
  }

  /// Toggle responder active status.
  Future<void> toggleResponderActive(
    String responderId,
    bool isActive,
  ) async {
    await _db
        .collection(kResponderLocationsCollection)
        .doc(responderId)
        .update({
      'isActive': isActive,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // ─── Chat ─────────────────────────────────────────────────

  /// Send a chat message in an emergency.
  Future<void> sendMessage({
    required String emergencyId,
    required ChatMessage message,
  }) async {
    await _db
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .add(message.toFirestore());
  }

  /// Stream chat messages for an emergency.
  Stream<List<ChatMessage>> streamMessages(String emergencyId) {
    return _db
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  /// Mark messages as read.
  Future<void> markMessagesRead({
    required String emergencyId,
    required String userId,
  }) async {
    final unread = await _db
        .collection(kEmergenciesCollection)
        .doc(emergencyId)
        .collection(kChatSubcollection)
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
