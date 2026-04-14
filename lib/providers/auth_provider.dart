import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../config/constants.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Provides the AuthService singleton.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provides the FirestoreService singleton.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Stream of Firebase Auth state changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

/// Current user model from Firestore (reactive).
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  final firestore = ref.read(firestoreServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return firestore.streamUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Auth state notifier for login/register actions.
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref)
      : super(const AsyncValue.data(null));

  /// Register with email/password.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
        role: role,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign in with email/password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Continue without sign-up using anonymous auth.
  Future<void> continueAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signInAsGuest();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Start phone OTP verification.
  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (id, _) => onCodeSent(id),
      onAutoVerified: (credential) async {
        // Auto-verification on Android
        final result =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (result.user != null) {
          final userModel =
              await _authService.getCurrentUserModel();
          state = AsyncValue.data(userModel);
        }
      },
      onError: (error) => onError(error.message ?? 'Verification failed'),
    );
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.read(authServiceProvider), ref);
});
