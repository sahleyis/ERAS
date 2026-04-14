import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';
import '../models/user_model.dart';

/// Authentication service handling sign-up, login, and session management.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current Firebase user (null if not logged in).
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  // ─── Email / Password Auth ─────────────────────────────────

  /// Register a new user with email and password.
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required UserRole role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);

    final user = UserModel(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
      phone: phone,
      role: role,
    );

    // Create user document in Firestore
    await _firestore
        .collection(kUsersCollection)
        .doc(user.uid)
        .set(user.toFirestore());

    // If responder, create location tracking document
    if (role == UserRole.responder || role == UserRole.both) {
      await _firestore
          .collection(kResponderLocationsCollection)
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'isActive': false,
        'specialization': Specialization.firstAid.name,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  /// Sign in with email and password.
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user == null) return null;

    return _getUserModel(credential.user!.uid);
  }

  // ─── Phone Auth (OTP) ─────────────────────────────────────

  /// Start phone number verification (sends OTP).
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken)
        onCodeSent,
    required void Function(PhoneAuthCredential credential)
        onAutoVerified,
    required void Function(FirebaseAuthException error) onError,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: resendToken,
      verificationCompleted: onAutoVerified,
      verificationFailed: onError,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Verify OTP code and sign in.
  Future<UserModel?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final result = await _auth.signInWithCredential(credential);
    if (result.user == null) return null;

    return _getUserModel(result.user!.uid);
  }

  // ─── Session Management ────────────────────────────────────

  /// Get the current user's model from Firestore.
  Future<UserModel?> getCurrentUserModel() async {
    if (currentUser == null) return null;
    return _getUserModel(currentUser!.uid);
  }

  /// Sign out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete the current user's account and data.
  Future<void> deleteAccount() async {
    if (currentUser == null) return;

    final uid = currentUser!.uid;

    // Delete Firestore data
    await _firestore.collection(kUsersCollection).doc(uid).delete();
    await _firestore
        .collection(kResponderLocationsCollection)
        .doc(uid)
        .delete();

    // Delete Firebase Auth account
    await currentUser!.delete();
  }

  // ─── Helpers ───────────────────────────────────────────────

  Future<UserModel?> _getUserModel(String uid) async {
    final doc =
        await _firestore.collection(kUsersCollection).doc(uid).get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
