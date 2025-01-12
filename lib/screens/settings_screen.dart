import 'package:flutter/material.dart';
import '../services/book_service.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BookService _bookService = GetIt.I<BookService>();

  void _exportLibrary() async {
    try {
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an export location:',
        fileName: 'library.json',
      );

      if (filePath != null) {
        await _bookService.exportLibrary(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Library exported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export cancelled.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export library: $e')),
      );
    }
  }

  void _importLibrary() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        await _bookService.importLibrary(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Library imported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import cancelled.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import library: $e')),
      );
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
