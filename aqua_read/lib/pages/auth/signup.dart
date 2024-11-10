import 'package:aqua_read/pages/auth/auth_landing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/navigatorController.dart';
import '../../state_management/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> registerUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.registerWithEmail(
        _emailController.text,
        _passwordController.text,
        _displayNameController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(), // Background image of the screen
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 300), // Spacer to position content
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0), // Padding for the container
                    margin: const EdgeInsets.symmetric(horizontal: 24.0), // Margin for the container
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9), // Background color with opacity
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sign Up with Email',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Title style
                        ),
                        const SizedBox(height: 10), // Spacer
                        TextField(
                          controller: _displayNameController, // Controller for display name input
                          decoration: const InputDecoration(
                            labelText: 'Name', // Label for display name
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Padding for the text field
                          ),
                        ),
                        const SizedBox(height: 10), // Spacer
                        TextField(
                          controller: _emailController, // Email input field
                          decoration: const InputDecoration(
                            labelText: 'Email', // Label for email input
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Padding for text field
                          ),
                          keyboardType: TextInputType.emailAddress, // Email keyboard type
                        ),
                        const SizedBox(height: 10), // Spacer
                        PasswordField(controller: _passwordController), // Password input field
                        const SizedBox(height: 20), // Spacer
                        RegisterButton(onPressed: registerUser), // Registration button
                        const Divider(thickness: 1.5), // Divider between sections
                        const OldUserLoginLink(), // Link for existing users to log in
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BackButtonIcon(), // Back button for navigation
        ],
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'), // Background image asset
          fit: BoxFit.cover, // Cover the entire container
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller; // Controller for password input

  const PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, // Password input field
      decoration: const InputDecoration(
        labelText: 'Password', // Label for password input
        contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Padding for text field
      ),
      obscureText: true, // Ensures the password is obscured
    );
  }
}

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed; // Callback for registration action

  const RegisterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Registration button
      child: const Text('Register'), // Button text
    );
  }
}

class OldUserLoginLink extends StatelessWidget {
  const OldUserLoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Already have an account?'), // Text for existing users
        TextButton(
          onPressed: () {
            NavigationController(context).pushAndPopUntilRoot(AuthLandingPage()); // Navigates to login screen
          },
          child: const Text('Login'), // Button text for login
        ),
      ],
    );
  }
}

class BackButtonIcon extends StatelessWidget {
  const BackButtonIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 16,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white), // Back button icon
        onPressed: () => Navigator.pop(context), // Action for back button
      ),
    );
  }
}
