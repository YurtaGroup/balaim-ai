import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'demo_auth_service.dart';

/// Unified auth service — uses Firebase when available, falls back to demo mode.
/// This allows the app to work without Firebase configured.
class AuthService {
  final fb.FirebaseAuth? _firebaseAuth;
  final DemoAuthService _demoAuth;
  bool _useFirebase = false;

  AuthService({fb.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth,
        _demoAuth = DemoAuthService() {
    _useFirebase = _firebaseAuth != null;
  }

  bool get isFirebaseMode => _useFirebase;
  bool get isDemoMode => !_useFirebase;

  /// Current user email
  String? get currentUserEmail {
    if (_useFirebase) return _firebaseAuth!.currentUser?.email;
    return _demoAuth.currentUser?.email;
  }

  /// Current user display name
  String? get currentUserDisplayName {
    if (_useFirebase) return _firebaseAuth!.currentUser?.displayName;
    return _demoAuth.currentUser?.displayName;
  }

  /// Current user UID
  String? get currentUserUid {
    if (_useFirebase) return _firebaseAuth!.currentUser?.uid;
    return _demoAuth.currentUser?.uid;
  }

  /// Auth state stream — emits true when logged in, false when logged out
  Stream<bool> get authStateChanges {
    if (_useFirebase) {
      return _firebaseAuth!.authStateChanges().map((user) => user != null);
    }
    return _demoAuth.authStateChanges.map((user) => user != null);
  }

  /// Sign in with email/password
  Future<void> signInWithEmail(String email, String password) async {
    if (_useFirebase) {
      await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      await _demoAuth.signIn(email, password);
    }
  }

  /// Sign up with email/password
  Future<void> signUpWithEmail(String email, String password) async {
    if (_useFirebase) {
      await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } else {
      await _demoAuth.signIn(email, password);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_useFirebase) {
      await _firebaseAuth!.signOut();
    } else {
      await _demoAuth.signOut();
    }
  }

  /// Switch to demo mode (useful if Firebase fails)
  void fallbackToDemo() {
    _useFirebase = false;
  }
}
