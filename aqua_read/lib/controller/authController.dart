import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state_management/auth_provider.dart';

import 'navigatorController.dart';
import '../pages/auth/auth_test.dart';

class SignInMethods {
  void signInGoogle(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signInWithGoogle();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in from Google')),
      );
      NavigationController(context).pushAndPopUntilRoot(AuthTest());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Google: $e')),
      );
    }
  }


  void signInAsGuest(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signInAnonymously();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as Guest')),
      );
      NavigationController(context).pushAndPopUntilRoot(AuthTest());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in as Guest: $e')),
      );
    }
  }

  // Sign in with email and password
  void signInWithEmail(BuildContext context, String email, String password) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signInWithEmail(email, password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in with Email')),
      );
      NavigationController(context).pushAndPopUntilRoot(AuthTest());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in with Email: $e')),
      );
    }
  }
}