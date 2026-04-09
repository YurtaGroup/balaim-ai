import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../main.dart' show isFirebaseInitialized;
import 'demo_auth_service.dart';
import 'analytics_service.dart';
import 'notification_service.dart';
import 'payment_service.dart';

/// Unified auth service — Firebase when configured, demo fallback otherwise.
/// SINGLETON: ensures auth state is consistent across the entire app.
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  /// SINGLE demo auth instance — shared everywhere
  final DemoAuthService demo = DemoAuthService();

  bool get _useFirebase => isFirebaseInitialized;

  // ==========================================================
  // CURRENT USER
  // ==========================================================

  String? get currentUid {
    if (_useFirebase) return fb.FirebaseAuth.instance.currentUser?.uid;
    return demo.currentUser?.uid;
  }

  String? get currentEmail {
    if (_useFirebase) return fb.FirebaseAuth.instance.currentUser?.email;
    return demo.currentUser?.email;
  }

  String? get currentDisplayName {
    if (_useFirebase) return fb.FirebaseAuth.instance.currentUser?.displayName;
    return demo.currentUser?.displayName;
  }

  bool get isSignedIn => currentUid != null;

  /// The demo user object (for role checking). Null when Firebase is active.
  DemoUser? get currentDemoUser => _useFirebase ? null : demo.currentUser;

  // ==========================================================
  // AUTH STATE STREAM — the single source of truth for the router
  // ==========================================================

  Stream<bool> get authStateChanges {
    if (_useFirebase) {
      return fb.FirebaseAuth.instance
          .authStateChanges()
          .map((user) => user != null);
    }
    return demo.authStateChanges.map((user) => user != null);
  }

  /// Demo user stream — for role-based routing
  Stream<DemoUser?> get demoUserChanges => demo.authStateChanges;

  // ==========================================================
  // SIGN UP
  // ==========================================================

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      if (_useFirebase) {
        final cred = await fb.FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await cred.user?.updateDisplayName(displayName);

        if (cred.user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .set({
            'uid': cred.user!.uid,
            'email': email,
            'displayName': displayName,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'stage': null,
            'dueDate': null,
            'babyBirthDate': null,
          });
        }

        AnalyticsService().logSignUp(method: 'email');
        return AuthResult.success(cred.user!.uid);
      } else {
        final user = await demo.signIn(email, password);
        AnalyticsService().logSignUp(method: 'demo');
        return AuthResult.success(user.uid);
      }
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyError(e));
    } catch (e) {
      return AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  // ==========================================================
  // SIGN IN
  // ==========================================================

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (_useFirebase) {
        final cred = await fb.FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        AnalyticsService().logLogin(method: 'email');
        return AuthResult.success(cred.user!.uid);
      } else {
        final user = await demo.signIn(email, password);
        AnalyticsService().logLogin(method: 'demo');
        return AuthResult.success(user.uid);
      }
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyError(e));
    } catch (e) {
      return AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  // ==========================================================
  // SIGN OUT
  // ==========================================================

  Future<void> signOut() async {
    final uid = currentUid;
    if (uid != null) {
      await NotificationService().clearToken(uid);
    }
    await PaymentService().logOut();
    if (_useFirebase) {
      await fb.FirebaseAuth.instance.signOut();
    } else {
      await demo.signOut();
    }
  }

  // ==========================================================
  // GOOGLE SIGN-IN
  // ==========================================================

  Future<AuthResult> signInWithGoogle() async {
    try {
      if (!_useFirebase) {
        final user = await demo.signIn('parent@balam.ai', 'demo123');
        AnalyticsService().logLogin(method: 'google_demo');
        return AuthResult.success(user.uid);
      }

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('Sign-in cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await fb.FirebaseAuth.instance.signInWithCredential(credential);

      // Create Firestore profile if new user
      if (userCred.additionalUserInfo?.isNewUser == true && userCred.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'uid': userCred.user!.uid,
          'email': userCred.user!.email,
          'displayName': userCred.user!.displayName,
          'photoUrl': userCred.user!.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      AnalyticsService().logLogin(method: 'google');
      return AuthResult.success(userCred.user!.uid);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyError(e));
    } on PlatformException catch (e) {
      debugPrint('[Auth] Google PlatformException: ${e.code} ${e.message}');
      if (e.code == 'sign_in_canceled') {
        return AuthResult.failure('Sign-in cancelled.');
      }
      return AuthResult.failure('Google sign-in is not available. Please use email sign-in.');
    } catch (e) {
      debugPrint('[Auth] Google sign-in error: $e');
      return AuthResult.failure('Google sign-in failed. Please use email sign-in.');
    }
  }

  // ==========================================================
  // APPLE SIGN-IN
  // ==========================================================

  Future<AuthResult> signInWithApple() async {
    try {
      if (!_useFirebase) {
        final user = await demo.signIn('parent@balam.ai', 'demo123');
        AnalyticsService().logLogin(method: 'apple_demo');
        return AuthResult.success(user.uid);
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = fb.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCred = await fb.FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Apple only provides name on first sign-in
      if (userCred.user != null) {
        final appleDisplayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((s) => s != null && s.isNotEmpty).join(' ');

        if (appleDisplayName.isNotEmpty && (userCred.user!.displayName == null || userCred.user!.displayName!.isEmpty)) {
          await userCred.user!.updateDisplayName(appleDisplayName);
        }

        if (userCred.additionalUserInfo?.isNewUser == true) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCred.user!.uid)
              .set({
            'uid': userCred.user!.uid,
            'email': userCred.user!.email ?? appleCredential.email,
            'displayName': appleDisplayName.isNotEmpty ? appleDisplayName : 'Parent',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      AnalyticsService().logLogin(method: 'apple');
      return AuthResult.success(userCred.user!.uid);
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('[Auth] Apple auth exception: ${e.code} ${e.message}');
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult.failure('Sign-in cancelled.');
      }
      return AuthResult.failure('Apple sign-in failed. Please use email sign-in.');
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyError(e));
    } on PlatformException catch (e) {
      debugPrint('[Auth] Apple PlatformException: ${e.code} ${e.message}');
      return AuthResult.failure('Apple sign-in is not available. Please use email sign-in.');
    } catch (e) {
      debugPrint('[Auth] Apple sign-in error: $e');
      return AuthResult.failure('Apple sign-in failed. Please use email sign-in.');
    }
  }

  // ==========================================================
  // PASSWORD RESET
  // ==========================================================

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      if (_useFirebase) {
        await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        return AuthResult.success(null);
      } else {
        return AuthResult.success(null);
      }
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyError(e));
    }
  }

  // ==========================================================
  // ERROR FORMATTING
  // ==========================================================

  String _friendlyError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}

class AuthResult {
  final bool success;
  final String? uid;
  final String? error;

  const AuthResult._({required this.success, this.uid, this.error});

  factory AuthResult.success(String? uid) =>
      AuthResult._(success: true, uid: uid);

  factory AuthResult.failure(String error) =>
      AuthResult._(success: false, error: error);
}
