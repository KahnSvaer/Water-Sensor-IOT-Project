import 'package:aqua_read/constants/colors.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../services/camera_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ScansPage extends StatefulWidget {
  const ScansPage({super.key});

  @override
  _ScansPageState createState() => _ScansPageState();
}

class _ScansPageState extends State<ScansPage> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for lifecycle
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check permissions when app resumes
      _checkPermissions();
    }
  }

  // Method to re-check permissions
  Future<void> _checkPermissions() async {
    if (await Permission.camera.isDenied || await Permission.photos.isDenied) {
      setState(() {
        _selectedImage = null; // Clear the image if permission is denied
      });
    }
  }

  // Method to handle image selection from camera
  Future<void> _selectImageFromCamera() async {
    final image = await _cameraService.pickImageFromCamera(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Method to handle image selection from gallery
  Future<void> _selectImageFromGallery() async {
    final image = await _cameraService.pickImageFromGallery(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
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
          // Inner container with image and buttons
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
                  // Image container with selected image or placeholder icon
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

                  // Camera and Gallery buttons
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

          // Analyze button outside the inner container
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // Analyze function here
              },
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
