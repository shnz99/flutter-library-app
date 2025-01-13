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
    if (!Platform.isAndroid) return true;

    // For Android 13 and above
    if (await Permission.photos.request().isGranted &&
        await Permission.videos.request().isGranted) {
      return true;
    }
    // For Android 12 and below
    else if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  Future<void> _exportLibrary() async {
    try {
      if (Platform.isAndroid) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required to export library')),
            );
          }
          return;
        }
      }

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
  }

  Future<void> _importLibrary() async {
    try {
      if (Platform.isAndroid) {
        final hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission is required to import library')),
            );
          }
          return;
        }
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      
      if (result == null) return;

      String? filePath = result.files.single.path;
      if (filePath == null) throw Exception('Invalid file selection');
      
      if (!filePath.toLowerCase().endsWith('.json')) {
        throw Exception('Please select a JSON file');
      }

      await _bookService.importLibrary(filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Library imported successfully')),
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
