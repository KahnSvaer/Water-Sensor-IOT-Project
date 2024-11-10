import 'package:aqua_read/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../services/result_service.dart'; // Import ResultService

class ScansPage extends StatefulWidget {
  const ScansPage({super.key});

  @override
  _ScansPageState createState() => _ScansPageState();
}

class _ScansPageState extends State<ScansPage> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final ResultService _resultService = ResultService();  // Instantiate ResultService
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.isDenied || await Permission.photos.isDenied) {
      setState(() {
        _selectedImage = null;
      });
    }
  }

  Future<void> _selectImageFromCamera() async {
    final image = await _cameraService.pickImageFromCamera(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _selectImageFromGallery() async {
    final image = await _cameraService.pickImageFromGallery(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Function to handle analysis and save data using ResultService
  Future<void> _analyzeAndSaveData() async {
    if (_selectedImage != null) {
      // Analyze and save the result using the ResultService
      await _resultService.analyzeAndSaveStrip();

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data saved to database")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Scan your strip here",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!)
                            : Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _selectImageFromCamera,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(Icons.camera_alt, color: Colors.white),
                        label: Text(
                          "Camera",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _selectImageFromGallery,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(Icons.photo_library, color: Colors.white),
                        label: Text(
                          "Gallery",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Analyze button only shown if an image is selected
          if (_selectedImage != null)
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _analyzeAndSaveData, // Call the function when pressed
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Analyze",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
