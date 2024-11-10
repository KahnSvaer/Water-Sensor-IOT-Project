import 'package:aqua_read/controller/authController.dart';
import 'package:flutter/material.dart';
import 'option.dart';
import '../../controller/navigatorController.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final SignInMethods signInMethods = SignInMethods();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false; // Flag to track if OTP has been sent

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
                          readOnly: _isOtpSent, // Make field read-only if OTP is sent
                        ),
                        const SizedBox(height: 10),
                        if (_isOtpSent) ...[
                          TextField(
                            controller: _otpController,
                            decoration: const InputDecoration(
                              labelText: 'Enter OTP',
                              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () async {
                              String otp = _otpController.text.trim();
                              if (otp.isNotEmpty) {
                                signInMethods.verifyOTPLogin(context, _otpController.text);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter the OTP.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Verify OTP'),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (!_isOtpSent) ...[
                          ElevatedButton(
                            onPressed: () async {
                              String phoneNumber = '+91${_phoneController.text.trim()}';
                              if (phoneNumber.isNotEmpty) {
                                signInMethods.sendOTPtoPhoneLogin(context, phoneNumber);
                                setState(() {
                                  _isOtpSent = true; // Update state to indicate OTP was sent
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter a valid phone number.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Send OTP'),
                          ),
                        ],
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
