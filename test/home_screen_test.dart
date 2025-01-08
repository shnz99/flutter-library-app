import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/screens/home_screen.dart';
import 'package:flutter_library_app/models/book.dart';
import 'package:flutter_library_app/services/book_service.dart';

void main() {
  testWidgets('HomeScreen has a title and search field', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Verify that the HomeScreen has a title
    expect(find.text('Book Tracker'), findsOneWidget);

    // Verify that the HomeScreen has a search field
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search by title or author'), findsOneWidget);
  });

  testWidgets('HomeScreen displays books sorted alphabetically', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Verify that the HomeScreen displays books sorted alphabetically
    final bookTitles = tester.widgetList(find.byType(ListTile)).map((widget) => (widget as ListTile).title).toList();
    final sortedBookTitles = List.from(bookTitles)..sort();
    expect(bookTitles, sortedBookTitles);
  });

  testWidgets('HomeScreen filters books based on search query', (WidgetTester tester) async {
    final bookService = BookService();
    final sampleBook = Book(
      title: 'Sample Book',
      author: 'Sample Author',
      isbn: '1234567890',
      notes: 'Sample notes',
      rating: 4.5,
      readingProgress: 0.75,
    );
    await bookService.addBook(sampleBook);

    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Enter a search query
    await tester.enterText(find.byType(TextField), 'Sample Book');
    await tester.pump();

    // Verify that the HomeScreen filters books based on the search query
    final filteredBooks = tester.widgetList(find.byType(ListTile)).map((widget) => (widget as ListTile).title).toList();
    expect(filteredBooks, contains('Sample Book'));
  });
}
