import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http; // For making API calls
import 'package:google_sign_in/google_sign_in.dart'; // For Google Sign-In

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream to listen for authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password (WORKS DONT TOUCH)
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

  // Function to verify phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(PhoneAuthCredential) onAutoVerificationCompleted,
    required Function(String, int?) onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval callback, e.g., for instant verification in certain cases.
        onAutoVerificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Callback for failed verification attempts.
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        // Callback when the verification code is sent.
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Called when auto code retrieval times out.
      },
      timeout: const Duration(seconds: 60), // Customize the timeout as needed.
    );
  }

  // Function to verify OTP and sign in the user
  Future<User?> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      UserCredential userCredential = await _auth.signInWithCredential(
          credential);
      return userCredential.user;
    } catch (e) {
      print('Error during phone sign-in: $e');
      rethrow;
    }
  }

  // Function to register a user using phone number verification
  Future<void> registerWithPhoneNumber({
    required String phoneNumber,
    required String displayName,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(PhoneAuthCredential) onAutoVerificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification callback
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        User? user = userCredential.user;

        // Check if this is a new user and update the display name
        if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
          await user.updateDisplayName(displayName);
          await user.reload();
        }

        onAutoVerificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        // Triggered when the OTP is sent
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Code retrieval timeout
      },
      timeout: const Duration(seconds: 60),
    );
  }

  // Function to complete registration with the entered OTP
  Future<User?> registerWithOtp({
    required String verificationId,
    required String smsCode,
    required String displayName,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      // If it's a new user, update their display name
      if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
        await user.updateDisplayName(displayName);
        await user.reload();
      }

      return user;
    } catch (e) {
      print('Error during phone registration: $e');
      rethrow;
    }
  }
}