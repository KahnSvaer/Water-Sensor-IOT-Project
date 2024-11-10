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



  // Register with phone
  void sendOTPtoPhone(BuildContext context, String phoneNumber, String displayName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    List<String?> registrationResult;
    registrationResult = await authProvider.registerWithPhoneNumber(phoneNumber, displayName);
    String? errorMessage = registrationResult[0];
    if (registrationResult[1] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto Verified')),
      );
    } else if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send otp: $errorMessage')),
      );
    }
  }

  // Verify OTP at registration of user
  void verifyOTP(BuildContext context, String smsCode, String displayName) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      String? verificationId = authProvider.verificationID;
      await authProvider.registerWithOtpPhone(verificationId!, smsCode, displayName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP Verified, Registration Successful')),
      );
      NavigationController(context).pushAndPopUntilRoot(AuthTest());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: $e')),
      );
    }
  }

  // Login with phone
  void sendOTPtoPhoneLogin(BuildContext context, String phoneNumber) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    List<String?> registrationResult;
    registrationResult = await authProvider.loginWithPhoneNumber(phoneNumber);
    String? errorMessage = registrationResult[0];
    if (registrationResult[1] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto Verified')),
      );
    } else if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send otp: $errorMessage')),
      );
    }
  }

  // Verify OTP at Login of user
  void verifyOTPLogin(BuildContext context, String smsCode) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      String? verificationId = authProvider.verificationID;
      await authProvider.loginWithOtpPhone(verificationId!, smsCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP Verified, Registration Successful')),
      );
      NavigationController(context).pushAndPopUntilRoot(AuthTest());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify OTP: $e')),
      );
    }
  }

}