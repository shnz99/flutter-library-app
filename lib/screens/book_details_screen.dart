import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'package:get_it/get_it.dart';
import 'edit_book_screen.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  final BookService _bookService = GetIt.I<BookService>();

  BookDetailsScreen({super.key, required this.book});

  void _removeBook(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book'),
        content: Text('Are you sure you want to delete the book "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _bookService.deleteBook(book.isbn);
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _editBook(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBookScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editBook(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _removeBook(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (book.imageUrl != null)
                Center(
                  child: Image.network(book.imageUrl!),
                ),
              SizedBox(height: 16.0),
              Text(
                'Title: ${book.title}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                'Author: ${book.author}',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8.0),
              if (book.publishedDate != null)
                Text(
                  'Published Date: ${book.publishedDate}',
                  style: TextStyle(fontSize: 18),
                ),
              SizedBox(height: 8.0),
              if (book.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Description: ${book.description}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              if (book.averageRating != null)
                RatingBarIndicator(
                  rating: book.averageRating!,
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                  direction: Axis.horizontal,
                ),
              SizedBox(height: 8.0),
              RatingBar.builder(
                initialRating: book.myRating ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  book.myRating = rating;
                  _bookService.updateBook(book);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
