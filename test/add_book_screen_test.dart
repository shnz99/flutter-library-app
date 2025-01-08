import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/screens/add_book_screen.dart';

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
    expect(find.text('Add Book'), findsOneWidget);
  });

  testWidgets('AddBookScreen has a notes field', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddBookScreen()));

    // Verify that the AddBookScreen has a Notes form field
    expect(find.widgetWithText(TextFormField, 'Notes'), findsOneWidget);
  });
}
