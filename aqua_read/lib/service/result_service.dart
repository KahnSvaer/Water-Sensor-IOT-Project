import 'dart:async';

import 'package:aqua_read/controller/navigatorController.dart';
import 'package:aqua_read/entities/results.dart';
import 'package:aqua_read/pages/result_showcase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/sql_lite_controller.dart';
import '../controller/firstore_controller.dart';

import 'package:http/http.dart' as http;
import 'dart:convert'; // for JSON encoding
import 'dart:io';

class ResultService {
  final SqlLiteController _sqlLiteService = SqlLiteController();
  final FirestoreController _firestoreService = FirestoreController();
  final ValueNotifier<Result?> latestTestResult = ValueNotifier<Result?>(null);

  // Load the asset image as bytes
  Future<Uint8List> _loadAssetImage(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }
  Future<Map<String, dynamic>?> sendImageRequest(String imageURL) async {
    String url = 'https://water-sensor-aqua-read.onrender.com/process_image';  // Replace with your API URL

    File imageFile = File(imageURL);
    Uint8List templateBytes = await _loadAssetImage('assets/images/Logo2-final.png');

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    request.files.add(http.MultipartFile.fromBytes('template', templateBytes, filename: 'Logo2-final.png'));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        String cleanedResponseBody = responseBody.replaceAll(r'\"', '"').trim();
        cleanedResponseBody = cleanedResponseBody.startsWith('"') && cleanedResponseBody.endsWith('"')
            ? cleanedResponseBody.substring(1, cleanedResponseBody.length - 1)
            : cleanedResponseBody;
        var jsonResponse = json.decode(cleanedResponseBody);
        return jsonResponse;

      } else {
        print('Request failed with status: ${response.statusCode}');
        return null;  // Return null if request fails
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;  // Return null if an error occurs
    }
  }

  Future<void> analyzeAndSaveStrip(BuildContext context, String imageURL) async {
    Completer<Result?> completer = Completer<Result?>();

    NavigationController(context).push(
      ResultWidgetPage(futureResult: completer.future),
    );

    String toHex(int value) {
      return value.toRadixString(16).padLeft(2, '0').toUpperCase();
    }

    String rgbToHex(int r, int g, int b) {
      String hex = '#${toHex(r)}${toHex(g)}${toHex(b)}';
      return hex;
    }

    try {
      var response = await sendImageRequest(imageURL);

      if (response?['error'] != "") {
        // If there's an error, show a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Incorrect Image received")),
        );
        completer.complete(null); // Complete the future with null
        return;
      }

      List<dynamic> colors = response?['colors'];
      List<String> hexColors = colors.map((color) {
        return rgbToHex(color[0].toInt(), color[1].toInt(), color[2].toInt());
      }).toList();
      response?['colors'] = hexColors;
      Result result = Result.fromJsonAPI(response!);
      latestTestResult.value = result;

      await _sqlLiteService.insertTestResult(result);
      await _firestoreService.insertTestResult(result);

      completer.complete(result); // Pass the result to the future
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      completer.completeError(e); // Complete the future with an error
    }
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
