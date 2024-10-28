import 'package:aqua_read/constants/colors.dart';
import 'package:flutter/material.dart';
import '../state_management/app_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<int> graphIndexNotifier = ValueNotifier<int>(0);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Extra Blue Container
          _buildExtraContainer(),

          SizedBox(height: 20),
          
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCustomDropdown(context, graphIndexNotifier),
                SizedBox(height: 20),
                _buildChartPlaceholder(graphIndexNotifier),
                SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          )
        ],
    );
  }

  // Widget for the Extra Blue Container
  Widget _buildExtraContainer() {
    return Container(
      color: AppColors.primaryColor,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Text(
        'Your Water Quality Data',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Custom Dropdown Widget with Animation starting from the bottom
  Widget _buildCustomDropdown(BuildContext context, ValueNotifier<int> graphIndexNotifier) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showDropdown(context, graphIndexNotifier);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    graphIndexNotifier.value == 0 ? "pH" : graphIndexNotifier.value == 1 ? "TDS" : "Other", // Display the selected value
                    style: TextStyle(fontSize: 16),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            // Show information about the selected quantity
          },
        ),
      ],
    );
  }

  // Show the dropdown options
  void _showDropdown(BuildContext context, ValueNotifier<int> graphIndexNotifier) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                title: Text("pH"),
                onTap: () {
                  graphIndexNotifier.value = 0; // Update graph index
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("TDS"),
                onTap: () {
                  graphIndexNotifier.value = 1; // Update graph index
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Other"),
                onTap: () {
                  graphIndexNotifier.value = 2; // Update graph index
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget for the Placeholder Chart Container
  Widget _buildChartPlaceholder(ValueNotifier<int> graphIndexNotifier) {
    return ValueListenableBuilder<int>(
      valueListenable: graphIndexNotifier, // Listen to changes
      builder: (context, value, child) {
        String displayText;
        switch (value) {
          case 0:
            displayText = 'pH Reading Graph'; // Change this to your graph
            break;
          case 1:
            displayText = 'TDS Reading Graph'; // Change this to your graph
            break;
          case 2:
            displayText = 'Other Reading Graph'; // Change this to your graph
            break;
          default:
            displayText = 'Select a quantity'; // Default text
        }

        return Container(
          height: 300, // Increased height for the graph
          width: double.infinity,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: Text(
            displayText, // Dynamic text based on selection
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        );
      },
    );
  }

  // Widget for Action Buttons
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            AppState().backgroundPageIndex.value = 0; // Update index for New Test
          },
          child: Text("Run a New Test"), // Updated button text
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            AppState().backgroundPageIndex.value = 2; // Update index for History
          },
          child: Text("View Test History"), // Updated button text
        ),
      ],
    );
  }
}
