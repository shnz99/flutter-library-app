import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/screens/book_details_screen.dart';
import 'package:flutter_library_app/models/book.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  testWidgets('BookDetailsScreen displays book details', (WidgetTester tester) async {
    final book = Book(
      title: 'Test Book',
      author: 'Test Author',
      isbn: '1234567890',
      notes: 'Test notes',
      rating: 4.5,
      readingProgress: 0.75,
    );

    await tester.pumpWidget(MaterialApp(home: BookDetailsScreen(book: book)));

    // Verify that the BookDetailsScreen displays the book title
    expect(find.text('Test Book'), findsOneWidget);

    // Verify that the BookDetailsScreen displays the book author
    expect(find.text('Test Author'), findsOneWidget);

    // Verify that the BookDetailsScreen displays the book notes
    expect(find.text('Test notes'), findsOneWidget);

    // Verify that the BookDetailsScreen displays the book rating
    expect(find.byType(RatingBar), findsOneWidget);

    // Verify that the BookDetailsScreen displays the reading progress
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
