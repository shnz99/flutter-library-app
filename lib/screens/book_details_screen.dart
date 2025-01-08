import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  _BookDetailsScreenState createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _notesController = TextEditingController();
  double _rating = 0.0;
  double _readingProgress = 0.0;
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.book.title;
    _authorController.text = widget.book.author;
    _notesController.text = widget.book.notes ?? '';
    _rating = widget.book.rating;
    _readingProgress = widget.book.readingProgress;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _editBookDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        isbn: widget.book.isbn,
        notes: _notesController.text,
        rating: _rating,
        readingProgress: _readingProgress,
      );
      await _bookService.updateBook(updatedBook);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Book details updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _addNotes() async {
    if (_formKey.currentState?.validate() ?? false) {
      await _bookService.addNotes(widget.book.isbn, _notesController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notes added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
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
                controller: _notesController,
                decoration: InputDecoration(labelText: 'Notes'),
                validator: (value) {
                  return null;
                },
              ),
              SizedBox(height: 20),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                value: _readingProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editBookDetails,
                child: Text('Edit Book Details'),
              ),
              ElevatedButton(
                onPressed: _addNotes,
                child: Text('Add Notes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
