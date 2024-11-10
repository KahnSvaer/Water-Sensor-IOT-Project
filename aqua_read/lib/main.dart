import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // Import the provider package

import 'pages/background.dart';
import 'pages/auth/auth_landing.dart';
import 'state_management/auth_provider.dart'; // Ensure the path is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(), // Create an instance of AuthProvider
      child: MaterialApp(
        title: 'AquaRead',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BackgroundPage(), // Your initial landing page
      ),
    );
  }
}
