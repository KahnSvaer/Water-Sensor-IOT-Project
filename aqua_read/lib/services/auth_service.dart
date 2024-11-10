import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // For Google Sign-In

class AuthService {
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

  // Function to register a user using phone number verification
  Future<User?> registerWithPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String) onUserAlreadyExists,
    required String displayName,
  }) async {
    User? autoRetrievedUser;

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async { //Function called in case of auto-retrieval of code
        try {
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          User? user = userCredential.user;

          if (user != null && userCredential.additionalUserInfo?.isNewUser == true){
            await user.updateDisplayName(displayName);
            await user.reload();
            autoRetrievedUser = user;
          }
          else if (user != null && userCredential.additionalUserInfo?.isNewUser == false){
            throw FirebaseAuthException(
              code: 'phone-number-already-in-use',
              message: 'This phone number is already registered.',
            );
          }
        } catch (e) {
          if (e is FirebaseAuthException && e.code == 'phone-number-already-in-use') {
            onUserAlreadyExists('This phone number is already registered.');
          } else {
            onVerificationFailed(FirebaseAuthException(
                code: 'unknown-error', message: e.toString()));
          }
        }
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
      timeout: const Duration(seconds: 120),
    );
    return autoRetrievedUser;
  }

  // Function to complete registration with the entered OTP
  Future<User?> registerWithOtpPhone({
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
      // THis would always be true as check for new user done previous code most prolly
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

  // Function to re-verify a user's phone number
  Future<User?> loginWithPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    User? autoRetrieval;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          User? user = userCredential.user;
          autoRetrieval = user;
        } catch (e) {
          onVerificationFailed(FirebaseAuthException(
            code: 'unknown-error',
            message: e.toString(),
          ));
        }
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
      timeout: const Duration(seconds: 120),
    );
    return autoRetrieval;
  }

  // Function to complete re-verification with the entered OTP
  Future<User?> loginWithOtpPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      return user;
    } catch (e) {
      print('Error during re-verification: $e');
      rethrow;
    }
  }
}