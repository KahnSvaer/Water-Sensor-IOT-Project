import 'package:flutter/material.dart';
import '../services/sql_lite_service.dart'; // Import HistoryService
import '../entities/results.dart'; // Ensure this import is correct

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final historyService = SqlLiteService();
    historyService.fetchTestResults();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0), // Add padding for better layout
        child: Column(
          children: [
            const Text(
              'History Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Result>?>(
                valueListenable: historyService.results,
                builder: (context, results, child) {
                  // If results are null, show loading, else show list or empty state
                  if (results == null) {
                    return const Center(
                      child: CircularProgressIndicator(), // Loading indicator
                    );
                  }

                  return results.isEmpty
                      ? const Center(
                          child: Text(
                            'Nothing to show yet.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            return ResultCard(
                              result: results[index],
                            );
                          },
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
  final Result result;

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
          padding: const EdgeInsets.all(16.0), // Padding for button
          side: const BorderSide(color: Colors.blue), // Outline color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Match card's corners
          ),
        ),
        onPressed: () {
          // Handle button press action
        },
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align items to the start
          children: [
            const Icon(Icons.calendar_today, size: 24), // Icon on the left
            const SizedBox(width: 8), // Spacing between icon and text
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to the start
              children: [
                Text(
                  "${result.date.toLocal()}".split(' ')[0], // Format the date
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4), // Spacing between date and result
                Text(
                  result.getDetails(), // Display the result details
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
