import 'package:flutter/material.dart';
import '../../controller/navigatorController.dart';
import 'email_auth.dart';
import 'phone_auth.dart';
import 'signup.dart';
import '../../controller/authController.dart';


class OtherSignInOptionsScreen extends StatelessWidget {
  const OtherSignInOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 200), // Adjust this as needed to position the container
                Center(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16,16,16,0),
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50, // Increased height for the button
                          child: ElevatedButton(
                            onPressed: () {
                              NavigationController(context).pushAndPopUntilRoot(EmailAuthScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Sign In with Email'),
                          ),
                        ),
                        const SizedBox(height: 7.5), // Reduced spacing
                        SizedBox(
                          width: double.infinity,
                          height: 50, // Increased height for the button
                          child: ElevatedButton(
                            onPressed: () => SignInMethods().signInGoogle(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Sign In with Google'),
                          ),
                        ),
                        const SizedBox(height: 7.5), // Reduced spacing
                        SizedBox(
                          width: double.infinity,
                          height: 50, // Increased height for the button
                          child: ElevatedButton(
                            onPressed: () {
                              NavigationController(context).pushAndPopUntilRoot(PhoneAuthScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Sign In with Phone'),
                          ),
                        ),
                        const SizedBox(height: 7.5), // Reduced spacing
                        SizedBox(
                          width: double.infinity,
                          height: 50, // Increased height for the button
                          child: ElevatedButton(
                            onPressed: () => SignInMethods().signInAsGuest(context),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Continue without Signing In'),
                          ),
                        ),

                        const SizedBox(height: 15), // Reduced spacing before the text button
                        const Divider(thickness: 1.5),
                        const SizedBox(height: 5), // Increased spacing
                        TextButton(
                          onPressed: () {
                            NavigationController(context).pushAndPopUntilRoot(RegistrationScreen());
                          },
                          child: const Text('New user? Register now',),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
          ),
        ],
      ),
    );
  }
}
