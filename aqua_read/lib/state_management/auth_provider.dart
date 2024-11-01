import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../entities/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user; // Store the current user

  // Expose the user as a getter
  User? get currentUser => _user;

  // Stream to listen for authentication state changes
  AuthProvider() {
    _authService.authStateChanges.listen((firebaseUser) {
      _updateCurrentUser(firebaseUser);
    });
  }

  // Helper method to convert firebase_auth.User to custom User
  User? _firebaseUserToUser(firebase_auth.User? user) {
    if (user == null) return null;
    return User(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      phoneNumber: user.phoneNumber ?? '', // You might want to remove this line as well if not needed
    );
  }

  // Private method to update the current user and notify listeners
  void _updateCurrentUser(firebase_auth.User? firebaseUser) {
    _user = _firebaseUserToUser(firebaseUser);
    notifyListeners();
  }

  // Register a new user with email (WORKS)
  Future<void> registerWithEmail(String email, String password, String displayName) async {
    final firebaseUser = await _authService.registerWithEmailAndDisplayName(email, password, displayName);
    _updateCurrentUser(firebaseUser);
  }

  // Sign in with Google (WORKS)
  Future<void> signInWithGoogle() async {
    final firebaseUser = await _authService.signInWithGoogle();
    _updateCurrentUser(firebaseUser);
  }

  // Sign in with email (WORKS)
  Future<void> signInWithEmail(String email, String password) async {
    final firebaseUser = await _authService.signInWithEmail(email, password);
    _updateCurrentUser(firebaseUser);
  }

  // Sign in anonymously as a guest (WORKS)
  Future<void> signInAnonymously() async {
    final firebaseUser = await _authService.signInAnonymously();
    _updateCurrentUser(firebaseUser);
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null; // Clear the current user
    notifyListeners();
  }
}
