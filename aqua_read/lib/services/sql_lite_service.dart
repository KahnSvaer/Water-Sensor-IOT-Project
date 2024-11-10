import 'package:flutter/material.dart';
import '../controller/sqlLiteController.dart';
import '../entities/results.dart'; // Ensure this import is correct

class SqlLiteService {
  // Create a ValueNotifier for results
  ValueNotifier<List<Result>?> results = ValueNotifier<List<Result>?>(null);

  // Fetch test results from SQLite and update the ValueNotifier
  Future<void> fetchTestResults() async {
    try {
      List<Map<String, dynamic>> dbResults = await LocalDatabaseHelper.instance.getTestResults();
      results.value = dbResults
          .map((data) => Result.fromMap(data)) // Use the Result.fromMap constructor to create Result instances
          .toList();
      print("Results Updated");

    } catch (e) {
      results.value = [];
      print("Error fetching results: $e");
    }
  }

  // Push a new test result into the SQLite table
  Future<void> insertTestResult(Result result) async {
    try {
      await LocalDatabaseHelper.instance.insertTestResult(result);
    } catch (e) {
      print("Error inserting result: $e");
    }
  }
}
