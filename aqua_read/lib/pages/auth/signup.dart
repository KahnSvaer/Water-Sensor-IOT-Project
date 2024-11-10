import 'package:aqua_read/controller/authController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/navigatorController.dart';
import '../../state_management/auth_provider.dart';
import 'option.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isOtpSent = false; // Tracks if the OTP has been sent
  bool _isEmailSignIn = false; // Tracks if the user is signing in with email
  bool _isVerified = false; // Tracks if the OTP has been verified
  String? verificationID;

  // Toggles between email and phone sign-in methods
  void toggleSignInMethod() {
    setState(() {
      _isEmailSignIn = !_isEmailSignIn; // Switches sign-in method
      _isOtpSent = false; // Resets OTP sent state
      _isVerified = false; // Resets verification state
      _emailController.clear(); // Clears email input
      _phoneController.clear(); // Clears phone number input
      _passwordController.clear(); // Clears password input
      _displayNameController.clear(); // Clears display name input
      FocusScope.of(context).unfocus(); // Removes focus from text fields
    });
  }

  // Function to handle OTP button press
  void handleOtpSending() {
    setState(() {
      if (!_isOtpSent) { // If OTP has not been sent
        if (_isEmailSignIn && _emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email.')));
          return;
        } else if (!_isEmailSignIn && _phoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your phone number.')));
          return;
        }
        _isOtpSent = true; // Set OTP sent state to true
        if (!_isEmailSignIn) {
          SignInMethods _signInMethods = SignInMethods();
          _signInMethods.sendOTPtoPhone(context, '+91${_phoneController.text}', _displayNameController.text);
        }
      } else if (!_isVerified) { // If OTP has been sent and not verified
        _isVerified = true; // Set verified state to true
      }
    });
  }

  // Function to handle OTP button press
  void handleOtpVerification() {
    setState(() {
      if (!_isVerified) { // If OTP has been sent and not verified
        _isVerified = true; // Set verified state to true
        SignInMethods _signInMethods = SignInMethods();
        _signInMethods.verifyOTP(context, '+91${_phoneController.text}', _displayNameController.text);
      }
    });
  }

  Future<void> registerUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isEmailSignIn) { // If signing up with email
        await authProvider.registerWithEmail(
          _emailController.text,
          _passwordController.text,
          _displayNameController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      } else {
        // TODO: Implement registration with phone
      }
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
                          _isEmailSignIn ? 'Sign Up with Email' : 'Sign Up with Phone Number',
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
                        ConditionalInputField(
                          isEmailSignIn: _isEmailSignIn,
                          emailController: _emailController, // Controller for email input
                          phoneController: _phoneController, // Controller for phone input
                          toShow: (!_isOtpSent && !_isVerified), // Shows input fields based on state
                        ),
                        const SizedBox(height: 10), // Spacer
                        if (_isVerified) ...[ // Display this if verified
                          const VerifiedIcon(), // Icon to show verification
                          const SizedBox(height: 10), // Spacer
                          if (_isEmailSignIn)
                            PasswordField(controller: _passwordController), // Password input field
                        ],
                        const SizedBox(height: 10), // Spacer
                        if (!_isVerified && _isOtpSent) const OtpField(), // OTP input field if OTP sent
                        const SizedBox(height: 10), // Spacer
                        // Separate buttons for sending and verifying OTP
                        if (!_isVerified && !_isOtpSent)
                          ElevatedButton(
                            onPressed: handleOtpSending, // Send OTP button
                            child: const Text('Send OTP'),
                          ),
                        if (!_isVerified && _isOtpSent)
                          ElevatedButton(
                            onPressed: handleOtpVerification, // Verify OTP button
                            child: const Text('Verify OTP'),
                          ),
                        if (_isVerified)
                          RegisterButton(onPressed: registerUser), // Registration button after verification
                        const SizedBox(height: 20), // Spacer
                        TextButton(
                          onPressed: toggleSignInMethod, // Button to toggle sign-in method
                          child: Text(
                            _isEmailSignIn ? 'Sign in with Phone Number instead' : 'Sign in with Email instead',
                            style: const TextStyle(color: Colors.blue), // Button text style
                          ),
                        ),
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

class ConditionalInputField extends StatelessWidget {
  final bool isEmailSignIn; // Determines which input field to show
  final TextEditingController emailController; // Controller for email input
  final TextEditingController phoneController; // Controller for phone input
  final bool toShow; // Controls visibility of input fields

  const ConditionalInputField({
    required this.isEmailSignIn,
    required this.emailController,
    required this.phoneController,
    required this.toShow,
  });

  @override
  Widget build(BuildContext context) {
    return isEmailSignIn
        ? TextField(
      controller: emailController, // Email input field
      decoration: const InputDecoration(
        labelText: 'Email', // Label for email input
        contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Padding for text field
      ),
      keyboardType: TextInputType.emailAddress, // Email keyboard type
      enabled: toShow, // Enable/disable based on state
    )
        : TextField(
      controller: phoneController, // Phone number input field
      decoration: const InputDecoration(
        labelText: 'Phone Number', // Label for phone input
        prefixText: '+91 ', // Country code prefix
        contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Padding for text field
      ),
      keyboardType: TextInputType.phone, // Phone number keyboard type
      enabled: toShow, // Enable/disable based on state
    );
  }
}

class VerifiedIcon extends StatelessWidget {
  const VerifiedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.check, color: Colors.green); // Icon to indicate verification success
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

class OtpField extends StatelessWidget {
  const OtpField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Enter OTP', // Label for OTP input
        contentPadding: EdgeInsets.symmetric(vertical: 10.0), // Padding for text field
      ),
      keyboardType: TextInputType.number, // Number keyboard type
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
            NavigationController(context).pushAndPopUntilRoot(OtherSignInOptionsScreen()); // Navigates to login screen
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
