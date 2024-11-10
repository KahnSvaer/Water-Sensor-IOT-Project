import 'package:aqua_read/pages/auth/auth_landing.dart';
import 'package:flutter/material.dart';
import '../../controller/navigatorController.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isOtpSent = false;
  bool _isOtpVerified = false;

  void handleOtpAction() {
    setState(() {
      if (!_isOtpSent) {
        _isOtpSent = true;
      } else if (!_isOtpVerified) {
        _isOtpVerified = true;
        _isOtpSent = false;
      }
    });
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
                        const Text(
                          'Forget Password',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email or Phone Number',
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        if (_isOtpSent && !_isOtpVerified) OtpField(controller: _otpController),
                        const SizedBox(height: 10),
                        if (_isOtpVerified) ...[
                          const VerifiedIcon(),
                          const SizedBox(height: 10),
                          PasswordField(controller: _newPasswordController),
                        ],
                        const SizedBox(height: 20),
                        ActionButton(
                          isOtpSent: _isOtpSent,
                          isOtpVerified: _isOtpVerified,
                          onPressed: handleOtpAction,
                        ),
                        const SizedBox(height: 20),
                        BackToLoginLink(),
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

class OtpField extends StatelessWidget {
  final TextEditingController controller;

  const OtpField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Enter OTP',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
      keyboardType: TextInputType.number,
    );
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
        labelText: 'New Password',
        contentPadding: EdgeInsets.symmetric(vertical: 10.0),
      ),
      obscureText: true,
    );
  }
}

class VerifiedIcon extends StatelessWidget {
  const VerifiedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.check, color: Colors.green, size: 30);
  }
}

class ActionButton extends StatelessWidget {
  final bool isOtpSent;
  final bool isOtpVerified;
  final VoidCallback onPressed;

  const ActionButton({
    required this.isOtpSent,
    required this.isOtpVerified,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(isOtpVerified ? 'Reset Password' : isOtpSent ? 'Verify OTP' : 'Send OTP'),
      ),
    );
  }
}

class BackToLoginLink extends StatelessWidget {
  const BackToLoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        NavigationController(context).pushAndPopUntilRoot(AuthLandingPage());
      },
      child: const Text('Other Sign In options'),
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
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
