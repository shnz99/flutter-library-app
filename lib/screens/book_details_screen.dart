import 'package:flutter/material.dart';
import '../models/book.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            if (book.year != null)
              Text(
                'Year: ${book.year}',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 8.0),
            if (book.firstAppearanceYear != null)
              Text(
                'First Appearance Year: ${book.firstAppearanceYear}',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 8.0),
            if (book.description != null)
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Description: ${book.description}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
