import 'package:flutter/material.dart';
import '../models/book.dart';
import '../screens/book_details_screen.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: book.imageUrl != null && book.imageUrl!.isNotEmpty
          ? FadeInImage.assetNetwork(
              placeholder: 'assets/images/placeholder.png', // Local placeholder image
              image: book.imageUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/placeholder.png', // Local placeholder image
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                );
              },
            )
          : SizedBox(width: 50, height: 50), // Empty space when there is no image
      title: Text(book.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.author),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: book.readingProgress, // Updated to use book's reading progress
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 4),
          Text('Rating: ${book.rating}'), // Display book rating
        ],
      ),
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
