// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter/foundation.dart'; // for kIsWeb

// class AuthService {
//   // Singleton instance
//   AuthService._internal();
//   static final AuthService instance = AuthService._internal();

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
//   bool _initialized = false;

//   /// Initializes the GoogleSignIn plugin.
//   /// Call this once at app startup (especially important on Web and desktop).
//   Future<void> initialize() async {
//     if (_initialized) return;
//     try {
//       await _googleSignIn.initialize();
//       _initialized = true;
//     } catch (e) {
//       // Initialization failed (network issues, etc.)
//       debugPrint('GoogleSignIn initialization error: $e');
//     }
//   }

//   /// Ensures GoogleSignIn is initialized before use.
//   Future<void> _ensureInitialized() async {
//     if (!_initialized) {
//       await initialize();
//     }
//   }

//   /// Signs in the user with Google and Firebase (returns Firebase UserCredential).
//   /// Returns null if the sign-in was cancelled or failed.
//   Future<UserCredential?> signInWithGoogle() async {
//     await _ensureInitialized();
//     try {
//       // Trigger the Google Sign-In flow.
//       final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
//         scopeHint: ['email'], // Request email scope (default for Firebase)
//       );
//       // Get the authentication tokens from the request
//       final GoogleSignInAuthentication googleAuth = googleUser.authentication;
//       final String? idToken = googleAuth.idToken;
//       // Request an OAuth access token for 'email' scope (if needed)
//       final authClient = _googleSignIn.authorizationClient;
//       GoogleSignInClientAuthorization? authorization =
//           await authClient.authorizationForScopes(['email']);
//       authorization ??= await authClient.authorizeScopes(['email']);
//       final String? accessToken = authorization.accessToken;

//       if (idToken == null) {
//         // Missing ID token
//         debugPrint('GoogleSignIn returned null idToken');
//         return null;
//       }
//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         idToken: idToken,
//         accessToken: accessToken,
//       );
//       // Sign in to Firebase with this credential
//       return await _auth.signInWithCredential(credential);
//     } on FirebaseAuthException catch (e) {
//       debugPrint('FirebaseAuth error during Google Sign-In: ${e.message}');
//       return null;
//     } on GoogleSignInException catch (e) {
//       debugPrint('GoogleSignIn exception (code: ${e.code}, message: ${e.description})');
//       return null;
//     } catch (e) {
//       debugPrint('Unexpected error in signInWithGoogle: $e');
//       return null;
//     }
//   }

//   /// Attempts to sign in a previously signed-in user silently (no UI).
//   /// Returns the Firebase UserCredential, or null if no previous sign-in exists.
//   Future<UserCredential?> signInSilently() async {
//     await _ensureInitialized();
//     try {
//       // Lightweight sign-in (may still show UI on some platforms)
//       final result = _googleSignIn.attemptLightweightAuthentication();
//       GoogleSignInAccount? googleUser;
//       if (result is Future<GoogleSignInAccount?>) {
//         googleUser = await result;
//       } else {
//         googleUser = result as GoogleSignInAccount?;
//       }
//       if (googleUser == null) {
//         // No user is currently signed in
//         return null;
//       }
//       final GoogleSignInAuthentication googleAuth = googleUser.authentication;
//       final String? idToken = googleAuth.idToken;
//       if (idToken == null) {
//         debugPrint('Silent sign-in returned null idToken');
//         return null;
//       }
//       final credential = GoogleAuthProvider.credential(idToken: idToken);
//       return await _auth.signInWithCredential(credential);
//     } catch (e) {
//       debugPrint('Silent sign-in failed: $e');
//       return null;
//     }
//   }

//   /// Requests an OAuth access token for the given scopes (default 'email').
//   /// Returns the access token string, or null on failure.
//   Future<String?> getAccessToken() async {
//     await _ensureInitialized();
//     try {
//       // We assume the user is already signed in; attempt silent sign-in if needed.
//       // (Optional: you could ensure sign-in first)
//       final authClient = _googleSignIn.authorizationClient;
//       final scopes = <String>['email'];
//       GoogleSignInClientAuthorization? authorization =
//           await authClient.authorizationForScopes(scopes);
//       authorization ??= await authClient.authorizeScopes(scopes);
//       return authorization.accessToken;
//     } catch (e) {
//       debugPrint('Failed to get access token: $e');
//       return null;
//     }
//   }

//   /// Signs out from Google and Firebase.
//   Future<void> signOut() async {
//     try {
//       await _googleSignIn.signOut();
//       await _auth.signOut();
//     } catch (e) {
//       debugPrint('Error signing out: $e');
//     }
//   }

//   /// Returns true if a Firebase user is currently signed in.
//   bool isSignedIn() {
//     return _auth.currentUser != null;
//   }
// }
