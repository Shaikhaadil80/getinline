// =============================================================================
// GETINLINE FLUTTER - services/auth_service.dart
// Firebase Authentication Service with Google & Apple Sign-In
// Updated for all platforms (iOS, Android, Web, macOS) with latest packages
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;
import 'api_service.dart';
import 'database_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In configuration (add any required scopes, e.g., for Drive)
  // final GoogleSignIn _googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'email',
  //     'profile',
  //   ], // Add more scopes if needed, e.g., 'https://www.googleapis.com/auth/drive.file'
  //   clientId: kIsWeb
  //       ? '637951798588-4rfl1vciel4o1mip3mtfirg2j86s8fdc.apps.googleusercontent.com'
  //       : null,
  // ).;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  // Get current Google user (if signed in with Google)
  // GoogleSignInAccount? get currentGoogleUser => _googleSignIn.;

  // Get current Firebase user UID
  String? get currentUserUid => _auth.currentUser?.uid;

  // Check if user is signed in to Firebase
  bool get isSignedIn => _auth.currentUser != null;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =============================================================================
  // GOOGLE SIGN-IN
  // =============================================================================

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');
      await _googleSignIn.initialize(
        clientId: kIsWeb
            ? '637951798588-4rfl1vciel4o1mip3mtfirg2j86s8fdc.apps.googleusercontent.com'
            : null,
      );
      if (kIsWeb) {
        // ---------------------------------------------------------
        // WEB FLOW
        // ---------------------------------------------------------
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        // signInWithPopup is standard for Web. Use signInWithRedirect for mobile web browsers if preferred.
        final userCredential = await _auth.signInWithPopup(googleProvider);
        print('✅ Web Google sign-in successful: ${userCredential.user?.uid}');

        // Optional: Save UID to your database here
        await _dbService.saveUserUid(userCredential.user!.uid);

        return userCredential;
      } else {
        // ---------------------------------------------------------
        // NATIVE FLOW (Android, iOS, macOS)
        // ---------------------------------------------------------
        // 1. Trigger the Google Authentication flow
        final GoogleSignInAccount? googleUser = await _googleSignIn
            .authenticate(scopeHint: ['profile', 'email']);

        // If the user cancels the sign-in, return null
        if (googleUser == null) {
          print('❌ Google Sign-In cancelled by user');
          return null;
        }

        // 3. Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleUser.authentication.idToken,
        );

        // 4. Sign in to Firebase with the given credential
        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        print(
          '✅ Native Google sign-in successful: ${userCredential.user?.uid}',
        );

        // Optional: Save UID to your database here
        await _dbService.saveUserUid(userCredential.user!.uid);

        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.message}');
      throw AuthException('Firebase Auth Error: ${e.message}');
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      throw AuthException('Google Sign-In failed: $e');
    }
  }

  Future<UserCredential?> signInWithApple() async {
    try {
      print('🔐 Starting Apple Sign-In...');

      if (kIsWeb) {
        // Web flow using Firebase OAuth (popup)
        final appleProvider = OAuthProvider('apple.com');
        appleProvider.addScope('email');
        appleProvider.addScope('name');
        final userCredential = await _auth.signInWithPopup(appleProvider);
        print('✅ Firebase sign-in successful: ${userCredential.user?.uid}');
        if (userCredential.user != null) {
          await _dbService.saveUserUid(userCredential.user!.uid);
        }
        return userCredential;
      } else if (Platform.isIOS || Platform.isMacOS) {
        // Native iOS / macOS flow using sign_in_with_apple package
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final userCredential = await _auth.signInWithCredential(
          oauthCredential,
        );
        print('✅ Firebase sign-in successful: ${userCredential.user?.uid}');
        if (userCredential.user != null) {
          await _dbService.saveUserUid(userCredential.user!.uid);
        }
        return userCredential;
      } else {
        throw AuthException('Apple Sign-In is not supported on this platform');
      }
    } catch (e) {
      print('❌ Apple Sign-In error: $e');
      throw AuthException('Apple Sign-In failed: $e');
    }
  }

  // =============================================================================
  // EMAIL/PASSWORD SIGN-IN (Optional)
  // =============================================================================

  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print('🔐 Signing in with email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Email sign-in successful: ${userCredential.user?.uid}');
      if (userCredential.user != null) {
        await _dbService.saveUserUid(userCredential.user!.uid);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Email sign-in error: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found with this email');
        case 'wrong-password':
          throw AuthException('Incorrect password');
        case 'invalid-email':
          throw AuthException('Invalid email address');
        case 'user-disabled':
          throw AuthException('This account has been disabled');
        default:
          throw AuthException('Sign-in failed: ${e.message}');
      }
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      print('🔐 Creating account with email: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Account created successfully: ${userCredential.user?.uid}');
      if (userCredential.user != null) {
        await _dbService.saveUserUid(userCredential.user!.uid);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Sign-up error: ${e.code}');
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException('An account already exists with this email');
        case 'invalid-email':
          throw AuthException('Invalid email address');
        case 'weak-password':
          throw AuthException('Password is too weak');
        default:
          throw AuthException('Sign-up failed: ${e.message}');
      }
    }
  }

  // =============================================================================
  // SIGN OUT
  // =============================================================================

  Future<void> signOut() async {
    try {
      print('🔐 Signing out...');
      if (_auth.currentUser!.providerData.first.providerId == "google.com") {
              await _googleSignIn.initialize(
        clientId: kIsWeb
            ? '637951798588-4rfl1vciel4o1mip3mtfirg2j86s8fdc.apps.googleusercontent.com'
            : null,);
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        await _googleSignIn.disconnect();
      }
      }
      // Sign out from Firebase
      await _auth.signOut();
      // Clear local storage
      await _dbService.clearUserData();

      print('✅ Sign-out successful');
    } catch (e) {
      print('❌ Sign-out error: $e');
      throw AuthException('Sign-out failed: $e');
    }
  }

  // =============================================================================
  // USER MANAGEMENT
  // =============================================================================

  // Get current user token
  Future<String?> getCurrentUserToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken();
      if (token != null) {
        await _dbService.saveUserToken(token);
        await _apiService.setAuthToken(token);
      }
      return token;
    } catch (e) {
      print('❌ Error getting user token: $e');
      return null;
    }
  }

  // Refresh user token
  Future<String?> refreshToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final token = await user.getIdToken(true); // Force refresh
      if (token != null) {
        await _dbService.saveUserToken(token);
        await _apiService.setAuthToken(token);
      }
      return token;
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      await user.reload();
      print('✅ User profile updated');
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw AuthException('Failed to update profile: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        print('✅ Verification email sent');
      }
    } catch (e) {
      print('❌ Error sending verification email: $e');
      throw AuthException('Failed to send verification email: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      print('❌ Password reset error: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No user found with this email');
        case 'invalid-email':
          throw AuthException('Invalid email address');
        default:
          throw AuthException('Failed to send reset email: ${e.message}');
      }
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      await user.delete();
      await _dbService.clearUserData();
      print('✅ Account deleted');
    } catch (e) {
      print('❌ Error deleting account: $e');
      throw AuthException('Failed to delete account: $e');
    }
  }

  // Re-authenticate user with Google (required before sensitive operations)
  Future<void> reauthenticateWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthException('No user signed in');
      }

      // Trigger Google sign-in to get fresh credentials
      final GoogleSignInAccount ? googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],);
      if (googleUser == null) {
        throw AuthException('Google Sign-In cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Re-authentication successful');
    } catch (e) {
      print('❌ Re-authentication error: $e');
      throw AuthException('Re-authentication failed: $e');
    }
  }
}

// =============================================================================
// CUSTOM EXCEPTION
// =============================================================================

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
