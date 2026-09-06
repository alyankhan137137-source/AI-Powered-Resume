import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/config/app_config.dart';

/// Wraps Firebase Auth. Your existing login/signup screens should call
/// these methods instead of talking to FirebaseAuth directly, so the rest
/// of the app only ever depends on AppUser.
class AuthService {
  Stream<User?> get authStateChanges {
    if (AppConfig.useMockMode) return Stream.value(null);
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser {
    if (AppConfig.useMockMode) return null;
    return FirebaseAuth.instance.currentUser;
  }

  Future<AppUser> signInWithGoogle() async {
    if (AppConfig.useMockMode) {
      return AppUser(
        uid: 'mock-uid-123',
        email: AppConfig.mockEmail,
        displayName: 'Mock User',
      );
    }
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Sign in aborted by user');

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return _fetchOrCreateProfile(userCredential.user!);
  }

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (AppConfig.useMockMode) {
      return AppUser(
        uid: 'mock-uid-123',
        email: email,
        displayName: displayName,
      );
    }
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Perform updates in parallel to save time
    final appUser = AppUser(
      uid: credential.user!.uid,
      email: email,
      displayName: displayName,
    );

    await Future.wait([
      credential.user!.updateDisplayName(displayName),
      FirebaseFirestore.instance.collection('users').doc(appUser.uid).set(appUser.toJson()),
    ]);

    return appUser;
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (AppConfig.useMockMode) {
      if (email == AppConfig.mockEmail && password == AppConfig.mockPassword) {
        return AppUser(
          uid: 'mock-uid-123',
          email: AppConfig.mockEmail,
          displayName: 'Mock User',
        );
      } else {
        throw Exception('wrong-password');
      }
    }
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _fetchOrCreateProfile(credential.user!);
  }

  /// Call this from your existing "Continue with Google" button.
  Future<AppUser> signInWithGoogleCredential(OAuthCredential credential) async {
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return _fetchOrCreateProfile(userCredential.user!);
  }

  Future<AppUser> _fetchOrCreateProfile(User firebaseUser) async {
    final db = FirebaseFirestore.instance;
    // Try to get from cache first if offline, otherwise server
    final doc = await db.collection('users').doc(firebaseUser.uid).get();
    
    if (doc.exists) {
      return AppUser.fromJson(doc.data()!);
    }

    final appUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );

    // Save to Firestore but don't block the return of the user object 
    // if we already have the data locally.
    db.collection('users').doc(appUser.uid).set(appUser.toJson())
       .catchError((e) => debugPrint('Error creating profile: $e'));

    return appUser;
  }

  Future<void> sendPasswordReset(String email) async {
    if (AppConfig.useMockMode) return;
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    if (AppConfig.useMockMode) return;
    await GoogleSignIn().signOut();
    return FirebaseAuth.instance.signOut();
  }

  Future<void> updateTargetJobTitle(String uid, String jobTitle) async {
    if (AppConfig.useMockMode) return;
    return FirebaseFirestore.instance.collection('users').doc(uid).update({'targetJobTitle': jobTitle});
  }

  Future<void> updateDisplayName(String uid, String newName) async {
    if (AppConfig.useMockMode) return;
    await Future.wait([
      FirebaseAuth.instance.currentUser!.updateDisplayName(newName),
      FirebaseFirestore.instance.collection('users').doc(uid).update({'displayName': newName}),
    ]);
  }
}
