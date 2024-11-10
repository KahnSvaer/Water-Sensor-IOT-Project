import 'package:flutter/material.dart';
import '../service/firestore_service.dart';  // Import FirestoreController
import '../entities/results.dart';  // Ensure this import is correct

class FirestoreController {
  final FirestoneHelper firestoreController;

  // Create a ValueNotifier for results
  ValueNotifier<List<Result>?> results = ValueNotifier<List<Result>?>(null);

  FirestoreController() : firestoreController = FirestoneHelper();

  // Fetch test results from Firebase and update the ValueNotifier
  Future<void> fetchTestResults() async {
    try {
      List<Result> fetchedResults = await firestoreController.getResults();
      results.value = fetchedResults;
      print("Results Updated from Firebase");
    } catch (e) {
      results.value = [];
      print("Error fetching results from Firebase: $e");
    }
  }

  // Push a new test result into Firebase
  Future<void> insertTestResult(Result result) async {
    try {
      await firestoreController.saveResult(result);
      print("Result saved to Firebase successfully");
    } catch (e) {
      print("Error inserting result to Firebase: $e");
    }
  }
}
