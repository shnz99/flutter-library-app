import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen has a title and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Verify that the HomeScreen has a title
    expect(find.text('Book Tracker'), findsOneWidget);

    // Verify that the HomeScreen has an Add Book button
    expect(find.text('Add Book'), findsOneWidget);

    // Verify that the HomeScreen has a View Book Details button
    expect(find.text('View Book Details'), findsOneWidget);
  });

  testWidgets('HomeScreen navigates to BookDetailsScreen with correct book details', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Tap the 'View Book Details' button
    await tester.tap(find.text('View Book Details'));
    await tester.pumpAndSettle();

    // Verify that the BookDetailsScreen is displayed with the correct book details
    expect(find.text('Sample Book'), findsOneWidget);
    expect(find.text('Sample Author'), findsOneWidget);
    expect(find.text('Sample notes'), findsOneWidget);
  });

  testWidgets('HomeScreen has a title and form fields', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Verify that the HomeScreen has a title
    expect(find.text('Book Tracker'), findsOneWidget);

    // Verify that the HomeScreen has a search field
    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search by title or author'), findsOneWidget);

    // Verify that the HomeScreen has an Add Book button
    expect(find.text('Add Book'), findsOneWidget);

    // Verify that the HomeScreen has a View Book Details button
    expect(find.text('View Book Details'), findsOneWidget);
  });

  testWidgets('HomeScreen has a notes field', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Tap the 'View Book Details' button
    await tester.tap(find.text('View Book Details'));
    await tester.pumpAndSettle();

    // Verify that the BookDetailsScreen is displayed with the correct book details
    expect(find.text('Sample notes'), findsOneWidget);
  });
}
