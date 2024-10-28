// home_page.dart

import 'package:flutter/material.dart';
import '../state_management/app_state.dart'; // Import the AppState singleton
import '../widgets/custom_bottom_nav_bar.dart'; // Import the custom bottom nav bar
import '../constants/colors.dart';

class BackgroundPage extends StatelessWidget {
  final AppState appState = AppState();

  BackgroundPage({super.key}); // Get the singleton instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: appState.backgroundPageIndex, // Listen to the ValueNotifier
        builder: (context, index, child) {
          return Container(
            color: Colors.white70, // Change this to your background color
            child: Center(
              child: Text(
                'Current Page Index: $index', // Display current index
                style: TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
