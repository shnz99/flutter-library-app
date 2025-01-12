import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publishedDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _myRatingController = TextEditingController();
  final BookService _bookService = GetIt.I<BookService>();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.book.title;
    _authorController.text = widget.book.author;
    _isbnController.text = widget.book.isbn;
    _publishedDateController.text = widget.book.publishedDate?.toString() ?? '';
    _descriptionController.text = widget.book.description ?? '';
    _myRatingController.text = widget.book.myRating?.toString() ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _publishedDateController.dispose();
    _descriptionController.dispose();
    _myRatingController.dispose();
    super.dispose();
  }

  void _searchForBook() async {
    final query = _isbnController.text.isNotEmpty ? _isbnController.text : _titleController.text;
    if (query.isEmpty) {
      _showErrorMessage('Please enter a title or ISBN');
      return;
    }

    final isISBN13 = RegExp(r'^\d{13}$').hasMatch(query);
    final isISBN10 = RegExp(r'^\d{10}$').hasMatch(query);

    final url = isISBN13
        ? Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$query')
        : isISBN10
            ? Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn10:$query')
            : Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query');

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

  void _saveBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        isbn: _isbnController.text,
        publishedDate: int.tryParse(_publishedDateController.text),
        description: _descriptionController.text,
        myRating: double.tryParse(_myRatingController.text),
      );
      try {
        await _bookService.updateBook(updatedBook);
        _showSuccessMessage('Book updated successfully!');
        Navigator.pop(context);
      } catch (e) {
        _showErrorMessage('Failed to update book');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                  decoration: InputDecoration(labelText: 'ISBN'),
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
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                RatingBar.builder(
                  initialRating: widget.book.myRating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _myRatingController.text = rating.toString();
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
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveBook,
                        child: Text('Save'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Discard'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
