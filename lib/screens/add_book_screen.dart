import 'package:flutter/material.dart';
import '../services/book_service.dart';
import '../models/book.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_it/get_it.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publishedDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final BookService _bookService = GetIt.I<BookService>();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _publishedDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _searchForBook() async {
    final query = _isbnController.text.isNotEmpty ? _isbnController.text : _titleController.text;
    if (query.isEmpty) {
      _showErrorMessage('Please enter a title or ISBN');
      return;
    }

    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['totalItems'] > 0) {
        final bookData = data['items'][0]['volumeInfo'];
        setState(() {
          _titleController.text = bookData['title'] ?? '';
          _authorController.text = bookData['authors']?.join(', ') ?? '';
          _isbnController.text = bookData['industryIdentifiers']?.firstWhere((id) => id['type'] == 'ISBN_13', orElse: () => null)?['identifier'] ?? '';
          _publishedDateController.text = bookData['publishedDate']?.split('-')?.first ?? '';
          _descriptionController.text = bookData['description'] ?? '';
        });
        _showSuccessMessage('Book details updated successfully!');
      } else {
        _showErrorMessage('No book found');
      }
    } else {
      _showErrorMessage('Failed to fetch book details');
    }
  }

  void _scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode) {
        setState(() {
          _isbnController.text = result.rawContent;
        });
        _searchForBook();
      }
    } catch (e) {
      _showErrorMessage('Failed to scan barcode');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      final book = Book(
        title: _titleController.text,
        author: _authorController.text,
        isbn: _isbnController.text,
        publishedDate: int.tryParse(_publishedDateController.text),
        description: _descriptionController.text,
      );
      try {
        await _bookService.addBook(book);
        _showSuccessMessage('Book added successfully!');
      } catch (e) {
        _showErrorMessage('Failed to add book');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the book title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the author';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _isbnController,
                decoration: InputDecoration(labelText: 'ISBN 13'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the ISBN';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _publishedDateController,
                decoration: InputDecoration(labelText: 'Published Date'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the published date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _searchForBook,
                      child: Text('Search for Book'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _scanBarcode,
                      child: Text('Scan Barcode'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addBook,
                      child: Text('Submit Book'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
