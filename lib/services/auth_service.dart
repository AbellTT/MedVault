import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:app/services/database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle({bool isLoginOnly = false}) async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      // If the user cancels the sign-in
      if (googleUser == null) {
        return null;
      }
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // If we only want to log in, but this is a new user, delete the account
      if (isLoginOnly && userCredential.additionalUserInfo?.isNewUser == true) {
        // Sign out of Google to clear the session
        await _googleSignIn.signOut();
        // Delete the newly created Firebase user
        await userCredential.user?.delete();
        // Clear Firebase session
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
              'No account found for this Google email. Please sign up first.',
        );
      }
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        final user = userCredential.user;

        await DatabaseService().createOrUpdateUserData({
          'account_info': {
            'email': user?.email,
            'profile_picture': user?.photoURL,
            'created_at': FieldValue.serverTimestamp(),
          },
          'setup_complete': false,
        });
      }
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/signup',
      (Route<dynamic> route) => false,
    );
  }
}
