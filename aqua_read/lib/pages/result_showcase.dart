import 'package:flutter/material.dart';
import '../entities/results.dart';
import '../controller/navigatorController.dart';

class ResultWidgetPage extends StatelessWidget {
  final Future<Result?>? futureResult;

  const ResultWidgetPage({Key? key, required this.futureResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => NavigationController(context).pop(), // Close dialog on outside tap
      child: Material(
        color: Colors.transparent, // Transparent background
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent dialog itself from being dismissed
            child: Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05, // 5% of the screen width
                vertical: MediaQuery.of(context).size.height * 0.05, // 5% of the screen height
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // 90% of the screen width
                height: MediaQuery.of(context).size.height * 0.8, // 80% of the screen height
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Results',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => NavigationController(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 2), // Underline below the heading
                    Expanded(
                      child: futureResult == null
                          ? const Center(child: CircularProgressIndicator()) // Fallback UI for null future
                          : FutureBuilder<Result?>(
                        future: futureResult,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // Show a loading indicator while waiting
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            // Show an error message if the future has an error
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            // Display the result when data is available
                            final result = snapshot.data!;
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Table(
                                    border: TableBorder.all(color: Colors.grey, width: 0.5),
                                    columnWidths: const {
                                      0: FlexColumnWidth(1), // Equal width for both columns
                                      1: FlexColumnWidth(1),
                                    },
                                    children: [
                                      _buildTableRow('Parameter', 'Value', isHeader: true),
                                      _buildTableRow('pH', result.pH),
                                      _buildTableRow('Total Alkalinity', result.totalAlkalinity),
                                      _buildTableRow('Hardness', result.hardness),
                                      _buildTableRow('Lead', result.lead),
                                      _buildTableRow('Copper', result.copper),
                                      _buildTableRow('Iron', result.iron),
                                      _buildTableRow('Chromium (Cr VI)', result.chromiumCrVI),
                                      _buildTableRow('Free Chlorine', result.freeChlorine),
                                      _buildTableRow('Bromine', result.bromine),
                                      _buildTableRow('Nitrate', result.nitrate),
                                      _buildTableRow('Nitrite', result.nitrite),
                                      _buildTableRow('Mercury', result.mercury),
                                      _buildTableRow('Sulfite', result.sulfite),
                                      _buildTableRow('Fluoride', result.fluoride),
                                    ],
                                  ),
                                  const SizedBox(height: 16), // Space before details section
                                  const Text(
                                    'Additional Details:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result.details.isNotEmpty
                                        ? result.details
                                        : 'No additional details provided.',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // If there's no data
                            return const Center(child: Text('No result found.'));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String parameter, String value, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader
          ? const BoxDecoration(color: Colors.blueAccent)
          : null, // Header background
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              parameter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHeader ? 16 : 14,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isHeader ? 16 : 14,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                color: isHeader ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
