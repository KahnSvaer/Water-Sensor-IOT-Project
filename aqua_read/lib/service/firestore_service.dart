import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../entities/results.dart';  // Ensure this import is correct

class FirestoneHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to save a Result to Firebase
  Future<void> saveResult(Result result) async {
    try {
      String userId = _auth.currentUser?.uid ?? '';

      // Ensure user is authenticated
      if (userId.isEmpty) {
        throw Exception("User not authenticated");
      }

      // Convert result to map for Firestore
      Map<String, dynamic> resultData = result.toMap();

      // Add userId to the data map
      resultData['userID'] = userId;

      // Save to 'results' collection, each document with auto-generated ID
      await _firestore.collection('results').add(resultData);
      print("Result saved successfully");
    } catch (e) {
      print("Error saving result: $e");
    }
  }

  // Method to retrieve all results for the current user
  Future<List<Result>> getResults() async {
    List<Result> results = [];
    try {
      String userId = _auth.currentUser?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception("User not authenticated");
      }

      QuerySnapshot querySnapshot = await _firestore
          .collection('results')
          .where('userID', isEqualTo: userId)
          .get();

      results = querySnapshot.docs.map((doc) {
        return Result.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error retrieving results: $e");
    }
    return results;
  }
}
