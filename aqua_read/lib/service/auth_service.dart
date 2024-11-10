import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // For Google Sign-In

class AuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen for authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return userCredential.user; // Return the authenticated user
    } catch (e) {
      print('Sign in failed: $e');
      return null; // Return null on failure
    }
  }

  // Register a new user with email and password (WORKS DONT TOUCH)
  Future<User?> registerWithEmailAndDisplayName(String email, String password,
      String displayName) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        await user.updateProfile(displayName: displayName);
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
      }
      return user; // Return the newly created user
    } catch (e) {
      print('Registration failed: $e');
      return null; // Return null on failure
    }
  }


  // Sign out
  Future<void> signOut() async {
    await _auth.signOut(); // Sign out the user
    await _googleSignIn.signOut(); // Sign out from Google as well
  }


  // Google sign-in (WORKS DONT TOUCH)
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!
          .authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in the user with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user; // Return the authenticated user
    } catch (e) {
      print('Google sign-in failed: $e');
      return null; // Return null on failure
    }
  }

  // Sign in with anonymous account (WORKS DONT TOUCH)
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth
          .signInAnonymously(); // Sign in as an anonymous user
      return userCredential.user; // Return the authenticated anonymous user
    } catch (e) {
      print('Anonymous sign-in failed: $e');
      return null; // Return null on failure
    }
  }
}
