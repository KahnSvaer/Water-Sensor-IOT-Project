import 'package:flutter/material.dart';

import '../state_management/app_state.dart'; // Import the AppState singleton
import '../constants/colors.dart';

import '../widgets/custom_bottom_nav_bar.dart'; // Import the custom bottom nav bar

import 'history.dart';
import 'home.dart';
import 'scan.dart';
import 'setting.dart';


class BackgroundPage extends StatelessWidget {
  final AppState appState = AppState();

  BackgroundPage({super.key}); // Get the singleton instance

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      ScansPage(),     // Replace with your actual ScanPage widget
      HomePage(),     // Replace with your actual HomePage widget
      HistoryPage(),  // Replace with your actual HistoryPage widget
      SettingPage(), // Replace with your actual SettingsPage widget
    ];


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
              child: pages[index],
            ),
          );
        },
      ),

      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
