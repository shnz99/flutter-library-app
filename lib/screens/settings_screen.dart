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
  bool _isLoading = false;

  void _exportLibrary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'library_export.json',
      );

      if (outputFile != null) {
        await _bookService.exportLibrary(outputFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Library exported successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export library: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _importLibrary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        await _bookService.importLibrary(result.files.single.path!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Library imported successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import library: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            if (_isLoading)
              CircularProgressIndicator()
            else ...[
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
          ],
        ),
      ),
    );
  }
}
