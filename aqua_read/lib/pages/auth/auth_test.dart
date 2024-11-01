import 'package:aqua_read/state_management/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Get user details from the AuthProvider
    final email = authProvider.currentUser?.email ?? 'Empty';
    final phoneNumber = authProvider.currentUser?.phoneNumber ?? 'Empty';
    final displayName = authProvider.currentUser?.displayName ?? 'Not signed in';

    return Scaffold(
      appBar: AppBar(
        title: Text('Auth Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone Number: $phoneNumber',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Display Name: $displayName',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
