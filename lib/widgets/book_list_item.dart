import 'package:flutter/material.dart';
import '../models/book.dart';

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      width: double.infinity,
      child: ListTile(
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
            : Image.asset(
                'assets/images/placeholder.png', // Local placeholder image
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
        title: Text(book.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.author),
            if (book.year != null) Text('Year: ${book.year}'),
            if (book.description != null && book.description!.isNotEmpty)
              Text('Description: ${book.description}'),
          ],
        ),
      ),
    );
  }
}
