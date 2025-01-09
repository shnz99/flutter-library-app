import 'package:flutter/material.dart';
import '../services/book_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BookService _bookService = BookService();

  void _exportLibrary() async {
    // Implement the export functionality here
    // For example, you can use a file picker to select the export location
    // and then call _bookService.exportLibrary(filePath);
  }

  void _importLibrary() async {
    // Implement the import functionality here
    // For example, you can use a file picker to select the import file
    // and then call _bookService.importLibrary(filePath);
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
            ElevatedButton(
              onPressed: _exportLibrary,
              child: Text('Export Library'),
            ),
            ElevatedButton(
              onPressed: _importLibrary,
              child: Text('Import Library'),
            ),
          ],
        ),
      ),
    );
  }
}
