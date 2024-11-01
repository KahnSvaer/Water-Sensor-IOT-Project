import 'package:aqua_read/services/auth_service.dart';
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

  bool _isOtpSent = false;
  bool _isEmailSignIn = true;
  bool _isVerified = false;

  void toggleSignInMethod() {
    setState(() {
      _isEmailSignIn = !_isEmailSignIn;
      _isOtpSent = false;
      _isVerified = false;
      _emailController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _displayNameController.clear();
      FocusScope.of(context).unfocus();
    });
  }

  void handleOtpAction() {
    setState(() {
      if (!_isOtpSent) {
        if (_isEmailSignIn && _emailController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email.')));
          return;
        } else if (!_isEmailSignIn && _phoneController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your phone number.')));
          return;
        }
        _isOtpSent = true;
      } else if (!_isVerified) {
        _isVerified = true;
        _isOtpSent = false;
      }
    });
  }

  Future<void> registerUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isEmailSignIn) {
        await authProvider.registerWithEmail(
          _emailController.text,
          _passwordController.text,
          _displayNameController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful!')));
      } else {
        await authProvider.verifyPhoneNumber(
          _phoneController.text,
              (verificationId) {
            showOTPInputDialog(verificationId);
          },
              (errorMessage) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }


  void showOTPInputDialog(String verificationId) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: otpController,
            decoration: const InputDecoration(labelText: 'OTP'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final firebaseUser = await authProvider.verifyOTP(verificationId, otpController.text);
                  if (firebaseUser != null) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone verification successful!')));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 300),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.symmetric(horizontal: 24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isEmailSignIn ? 'Sign Up with Email' : 'Sign Up with Phone Number',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ConditionalInputField(
                          isEmailSignIn: _isEmailSignIn,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          isOtpSent: _isOtpSent,
                        ),
                        const SizedBox(height: 10),
                        if (_isVerified) ...[
                          const VerifiedIcon(),
                          const SizedBox(height: 10),
                          if (_isEmailSignIn)
                            PasswordField(controller: _passwordController),
                        ],
                        const SizedBox(height: 10),
                        if (!_isVerified && _isOtpSent) const OtpField(),
                        const SizedBox(height: 10),
                        if (!_isVerified)
                          OtpButton(
                            isOtpSent: _isOtpSent,
                            onPressed: handleOtpAction,
                          ),
                        if (_isVerified)
                          RegisterButton(onPressed: registerUser),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: toggleSignInMethod,
                          child: Text(
                            _isEmailSignIn ? 'Sign in with Phone Number instead' : 'Sign in with Email instead',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                        const Divider(thickness: 1.5),
                        const OldUserLoginLink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const BackButtonIcon(),
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
          image: AssetImage('assets/background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ConditionalInputField extends StatelessWidget {
  final bool isEmailSignIn;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final bool isOtpSent;

  const ConditionalInputField({
    required this.isEmailSignIn,
    required this.emailController,
    required this.phoneController,
    required this.isOtpSent,
  });

  @override
  Widget build(BuildContext context) {
    return isEmailSignIn
        ? TextField(
      controller: emailController,
      decoration: const InputDecoration(
        labelText: 'Email',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
      keyboardType: TextInputType.emailAddress,
      enabled: !isOtpSent,
    )
        : TextField(
      controller: phoneController,
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        prefixText: '+91 ',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
      keyboardType: TextInputType.phone,
      enabled: !isOtpSent,
    );
  }
}

class VerifiedIcon extends StatelessWidget {
  const VerifiedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.check, color: Colors.green);
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;

  const PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Password',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
      obscureText: true, // Ensure the password is obscured
    );
  }
}

class OtpField extends StatelessWidget {
  const OtpField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Enter OTP',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
      keyboardType: TextInputType.number,
    );
  }
}

class OtpButton extends StatelessWidget {
  final bool isOtpSent;
  final VoidCallback onPressed;

  const OtpButton({required this.isOtpSent, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(isOtpSent ? 'Verify OTP' : 'Send OTP'),
    );
  }
}

class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Register'),
    );
  }
}

class OldUserLoginLink extends StatelessWidget {
  const OldUserLoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Already have an account?'),
        TextButton(
          onPressed: () {
            NavigationController().pushAndPopUntilRoot(OtherSignInOptionsScreen());
          },
          child: const Text('Login'),
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
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
