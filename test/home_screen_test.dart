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
}
