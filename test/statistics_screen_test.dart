import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_library/screens/statistics_screen.dart';
import 'package:mobile_library/services/book_service.dart';
import 'package:mobile_library/models/book.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

void main() {
  group('StatisticsScreen Tests', () {
    late BookService bookService;

    setUp(() {
      bookService = BookService();
      GetIt.I.registerSingleton<BookService>(bookService);
    });

    tearDown(() {
      GetIt.I.reset();
    });

    testWidgets('StatisticsScreen displays sorted books by year and month', (WidgetTester tester) async {
      final books = [
        Book(title: 'Book 1', author: 'Author 1', isbn: '123', readDate: DateTime(2022, 1, 1)),
        Book(title: 'Book 2', author: 'Author 2', isbn: '456', readDate: DateTime(2022, 2, 1)),
        Book(title: 'Book 3', author: 'Author 3', isbn: '789', readDate: DateTime(2021, 1, 1)),
      ];

      await bookService.addBook(books[0]);
      await bookService.addBook(books[1]);
      await bookService.addBook(books[2]);

      await tester.pumpWidget(MaterialApp(home: StatisticsScreen()));

      await tester.pumpAndSettle();

      expect(find.text('2022'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
      expect(find.text('Month: 1'), findsNWidgets(2));
      expect(find.text('Month: 2'), findsOneWidget);
      expect(find.text('Book 1'), findsOneWidget);
      expect(find.text('Book 2'), findsOneWidget);
      expect(find.text('Book 3'), findsOneWidget);
    });

    testWidgets('StatisticsScreen shows no books found message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: StatisticsScreen()));

      await tester.pumpAndSettle();

      expect(find.text('No books found'), findsOneWidget);
    });
  });
}

