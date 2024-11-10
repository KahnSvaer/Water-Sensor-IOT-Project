import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromCamera(BuildContext context) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      return pickedFile != null ? File(pickedFile.path) : null;
    } else {
      _showPermissionDialog(context, "Camera");
      return null;
    }
  }

  Future<File?> pickImageFromGallery(BuildContext context) async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      return pickedFile != null ? File(pickedFile.path) : null;
    } else {
      _showPermissionDialog(context, "Gallery");
      return null;
    }
  }

  // Method to show permission dialog
  void _showPermissionDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$permissionType Permission Required"),
          content: Text(
            "This app needs $permissionType access to proceed. "
                "Please grant permission or open settings to enable it.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Permission.camera.request(); // Re-request permission
              },
              child: Text("Retry"),
            ),
            TextButton(
              onPressed: () {
                openAppSettings(); // Open settings if denied permanently
                Navigator.of(context).pop();
              },
              child: Text("Open Settings"),
            ),
          ],
        );
      },
    );
  }
}
