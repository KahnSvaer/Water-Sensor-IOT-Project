import 'package:aqua_read/entities/results.dart';
import 'package:flutter/cupertino.dart';
import 'sql_lite_controller.dart';
import 'firstore_controller.dart';

class ResultController {
  final SqlLiteController _sqlLiteService = SqlLiteController();
  final FirestoreController _firestoreService = FirestoreController();
  final ValueNotifier<Result?> latestTestResult = ValueNotifier<Result?>(null);

  // Method for analyzing the strip image and saving the result to SQLite
  Future<void> analyzeAndSaveStrip() async {
    // Simulate analysis delay
    await Future.delayed(Duration(seconds: 2));

    // Create a dummy result (you can replace this with actual image analysis logic)
    Result result = Result(
      date: DateTime.now(),
      details: "Test Result",
    );
    latestTestResult.value = result;

    // Save the result to SQLite
    await _sqlLiteService.insertTestResult(result);
    await _firestoreService.insertTestResult(result);
  }

  // Method to clear the latest test result
  void clearLatestResult() {
    latestTestResult.value = null;
  }

  // Method to update the latest test result if it's different
  void _updateLatestResult(Result result) {
    if (latestTestResult.value != result) {
      latestTestResult.value = result;
    }
  }
}
