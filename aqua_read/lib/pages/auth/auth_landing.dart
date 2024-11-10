import 'package:flutter/material.dart';
import '../../controller/auth_controller.dart';
import 'email_auth.dart';
import 'signup.dart';
import '../../controller/navigatorController.dart';

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center( // Center the inner widget
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200), // Space from top
                  Container(
                    padding: const EdgeInsets.fromLTRB(16,16,16,0),
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              NavigationController(context).pushAndPopUntilRoot(EmailAuthScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15.0), // More rectangular
                            ),
                            child: const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              NavigationController(context).pushAndPopUntilRoot(RegistrationScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15.0), // More rectangular
                            ),
                            child: const Text('Register'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(thickness: 1.5),
                        const SizedBox(height: 10),
                        const Text('Sign in using', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => SignInMethods().signInGoogle(context),
                          icon: const Icon(
                            Icons.g_mobiledata, // Default Google icon
                            color: Colors.black,
                          ),
                          label: const Text('Google'),
                          style: TextButton.styleFrom(
                            minimumSize: Size(double.infinity, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0), // Rounded corners
                            ),
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                        const SizedBox(height: 10), // Reduced space before Continue button
                        TextButton(
                          onPressed: () => SignInMethods().signInAsGuest(context),
                          child: const Text(
                            'Continue without signing in',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
