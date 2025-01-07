import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/book_details_screen.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  BookListItem({@required this.book});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsScreen(book: book),
          ),
        );
      },
    );
  }
}
