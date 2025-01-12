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
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need this permission
  }

  void _exportLibrary() async {
    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage permission is required to export library'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      
      if (selectedDirectory == null) {
        return; // User cancelled the picker
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String filePath = '$selectedDirectory${Platform.pathSeparator}library_export_$timestamp.json';
      
      await _bookService.exportLibrary(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Library exported successfully to: $filePath'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export library: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _importLibrary() async {
    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Storage permission is required to import library'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Changed to any to avoid extension filtering issues
        allowMultiple: false,
      );
      
      if (result == null) {
        return; // User cancelled the picker
      }

      String? filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('Invalid file selection');
      }

      // Verify if it's a JSON file
      if (!filePath.toLowerCase().endsWith('.json')) {
        throw Exception('Please select a JSON file');
      }

      await _bookService.importLibrary(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Library imported successfully'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import library: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
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
