import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state_management/auth_provider.dart';
import 'option.dart';
import '../../controller/navigatorController.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false; // Flag to track if OTP has been sent
  String? _verificationId; // Store verification ID for OTP verification

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
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                            prefixText: '+91 ', // Add country code prefix if needed
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),
                        if (_isOtpSent) ...[
                          TextField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              labelText: 'OTP',
                              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              if (_isOtpSent) {
                                // Handle OTP verification logic here
                                String otp = _otpController.text.trim();
                                if (otp.isNotEmpty && _verificationId != null) {
                                  await authProvider.registerWithOtp(_verificationId!, otp, 'Display Name'); // Replace 'Display Name' with actual display name
                                  // Navigate to the next screen after successful verification
                                } else {
                                  // Show error message if OTP is empty
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter the OTP.')),
                                  );
                                }
                              } else {
                                // Handle phone sign-in logic here
                                String phoneNumber = _phoneController.text.trim();
                                if (phoneNumber.isNotEmpty) {
                                  await authProvider.registerWithPhoneNumber(
                                    phoneNumber,
                                    'Display Name', // Replace 'Display Name' with actual display name
                                        (verificationId) {
                                      setState(() {
                                        _isOtpSent = true; // Mark that OTP has been sent
                                        _verificationId = verificationId; // Store the verification ID
                                      });
                                    },
                                        (errorMessage) {
                                      // Show error message on verification failure
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(errorMessage)),
                                      );
                                    },
                                  );
                                } else {
                                  // Show error message if phone number is empty
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a valid phone number.')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(thickness: 1.5),
                        TextButton(
                          onPressed: () {
                            NavigationController(context).pushAndPopUntilRoot(const OtherSignInOptionsScreen());
                          },
                          child: const Text('Other Sign-In Options'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
