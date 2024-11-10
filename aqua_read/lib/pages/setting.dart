import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider to access AuthProvider
import '../state_management/auth_provider.dart'; // Make sure the path is correct for AuthProvider

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the AuthProvider to get the current user's details
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser; // Assuming currentUser is a property in AuthProvider

    // If the user is not logged in, show a message
    if (user == null) {
      return Center(
        child: Text(
          'No user logged in',
          style: TextStyle(fontSize: 20),
        ),
      );
    }

    // If the user is logged in, display the user's information
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Settings Page',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Display Name: ${user.displayName ?? 'N/A'}', // Display the user's display name
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Email: ${user.email ?? 'N/A'}', // Display the user's email
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
