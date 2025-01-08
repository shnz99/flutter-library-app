import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/screens/add_book_screen.dart';
import 'package:flutter_library_app/services/book_service.dart';
import 'package:flutter_library_app/models/book.dart';

void main() {
  testWidgets('AddBookScreen has a title and form fields', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddBookScreen()));

    // Verify that the AddBookScreen has a title
    expect(find.text('Add Book'), findsOneWidget);

    // Verify that the AddBookScreen has a Title form field
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.widgetWithText(TextFormField, 'Title'), findsOneWidget);

    // Verify that the AddBookScreen has an Author form field
    expect(find.widgetWithText(TextFormField, 'Author'), findsOneWidget);

    // Verify that the AddBookScreen has an ISBN form field
    expect(find.widgetWithText(TextFormField, 'ISBN'), findsOneWidget);

    // Verify that the AddBookScreen has a Notes form field
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);

    // Verify that the AddBookScreen has buttons
    expect(find.text('Search for Book'), findsOneWidget);
    expect(find.text('Scan Barcode'), findsOneWidget);
    expect(find.text('Submit Book'), findsOneWidget);
  });

  testWidgets('AddBookScreen has a notes field', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddBookScreen()));

    // Verify that the AddBookScreen has a Notes form field
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
  });

  testWidgets('AddBookScreen adds a book and navigates back', (WidgetTester tester) async {
    final bookService = BookService();
    await tester.pumpWidget(MaterialApp(home: AddBookScreen()));

    // Enter text into the form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'Test Book');
    await tester.enterText(find.widgetWithText(TextFormField, 'Author'), 'Test Author');
    await tester.enterText(find.widgetWithText(TextFormField, 'ISBN'), '1234567890');
    await tester.enterText(find.widgetWithText(TextFormField, 'Notes'), 'Test notes');

    // Tap the 'Submit Book' button
    await tester.tap(find.text('Submit Book'));
    await tester.pumpAndSettle();

    // Verify that the book was added
    final books = await bookService.getBooks();
    expect(books.length, 1);
    expect(books.first.title, 'Test Book');
    expect(books.first.author, 'Test Author');
    expect(books.first.isbn, '1234567890');
    expect(books.first.notes, 'Test notes');

    // Verify that the screen navigated back
    expect(find.text('Add Book'), findsNothing);
  });
}
