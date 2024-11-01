import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Connection Check',
      home: FirebaseCheckPage(),
    );
  }
}

class FirebaseCheckPage extends StatefulWidget {
  @override
  _FirebaseCheckPageState createState() => _FirebaseCheckPageState();
}

class _FirebaseCheckPageState extends State<FirebaseCheckPage> {
  String _connectionStatus = "Checking Firebase connection...";

  @override
  void initState() {
    super.initState();
    checkFirebaseConnection();
  }

  Future<void> checkFirebaseConnection() async {
    try {
      await Firebase.initializeApp();
      setState(() {
        _connectionStatus = "Connected to Firebase!";
      });
    } catch (e) {
      setState(() {
        _connectionStatus = "Failed to connect to Firebase: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Connection Check"),
      ),
      body: Center(
        child: Text(
          _connectionStatus,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
