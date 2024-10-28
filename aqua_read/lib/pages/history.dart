import 'package:flutter/material.dart';

import '../entities/results.dart'; // Ensure this import is correct

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder for future fetched results
    List<AnalysisResult> results = [
      AnalysisResult(id: "1", date: "2024-10-01", result: "pH: 7.0, Turbidity: 5 NTU"),
      AnalysisResult(id: "2", date: "2024-10-05", result: "Chlorine: 1.5 mg/L"),
      AnalysisResult(id: "3", date: "2024-10-10", result: "Nitrate: 2.0 mg/L"),
      AnalysisResult(id: "4", date: "2024-10-15", result: "Lead: 0.01 mg/L"),

    ]; // Fake data for testing

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.0), // Add padding for better layout
        child: Column(
          children: [
            Text(
              'History Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: results.isEmpty
                  ? Center(
                child: Text(
                  'Nothing to show yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: results.length, // Use the fake data length
                itemBuilder: (context, index) {
                  return ResultCard(
                    result: results[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ResultCard extends StatelessWidget {
  final AnalysisResult result;

  const ResultCard({
    required this.result,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Slight elevation for visual depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(16.0), // Padding for button
          side: BorderSide(color: Colors.blue), // Outline color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Match card's corners
          ),
        ),
        onPressed: () {
          // Handle button press action
          print('${result.id} - ${result.date} pressed'); // Just for demonstration
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
          children: [
            Icon(Icons.calendar_today, size: 24), // Icon on the left
            SizedBox(width: 8), // Spacing between icon and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
              children: [
                Text(
                  result.date, // Display the date
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4), // Spacing between date and result
                Text(
                  result.result, // Display the result details
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

