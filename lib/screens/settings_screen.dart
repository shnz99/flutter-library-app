import 'package:flutter/material.dart';
import '../services/book_service.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BookService _bookService = GetIt.I<BookService>();

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Request both storage and manage storage permissions
      final storageStatus = await Permission.storage.request();
      final manageStorageStatus = await Permission.manageExternalStorage.request();
      
      // Return true if either permission is granted
      return storageStatus.isGranted || manageStorageStatus.isGranted;
    }
    return true; // For iOS or other platforms
  }

  Future<void> _handlePermissionAndProceed({required Function() onGranted}) async {
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Storage Permission Required'),
          content: Text('This feature requires storage permission. Please grant the permission in app settings.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      );
      return;
    }
    
    onGranted();
  }

  void _exportLibrary() async {
    await _handlePermissionAndProceed(
      onGranted: () async {
        try {
          String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
          if (selectedDirectory == null) return;

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          String filePath = '$selectedDirectory${Platform.pathSeparator}library_export_$timestamp.json';
          
          await _bookService.exportLibrary(filePath);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Library exported successfully to: $filePath')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to export library: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  void _importLibrary() async {
    await _handlePermissionAndProceed(
      onGranted: () async {
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            // Changed from custom type to any to avoid extension filtering issues
            type: FileType.any,
          );
          
          if (result == null) return;

          String? filePath = result.files.single.path;
          if (filePath == null) throw Exception('Invalid file selection');
          
          // Add validation for JSON file
          if (!filePath.toLowerCase().endsWith('.json')) {
            throw Exception('Please select a JSON file');
          }

          await _bookService.importLibrary(filePath);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Library imported successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to import library: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exportLibrary,
                    child: Text('Export Library'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _importLibrary,
                    child: Text('Import Library'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
