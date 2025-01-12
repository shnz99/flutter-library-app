import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/book.dart';
import 'package:my_app/services/book_service.dart';
import 'package:my_app/screens/book_details_screen.dart';

@GenerateMocks([BookService])
void main() {
  group('Book Details Screen Tests', () {
    late MockBookService mockBookService;

    setUp(() {
      mockBookService = MockBookService();
    });

    testWidgets('Test opening book details screen by clicking on a book', (WidgetTester tester) async {
      when(mockBookService.getBooks()).thenAnswer((_) async => [
        Book(title: 'Test Book', author: 'Test Author', isbn: '1234567890123'),
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<BookService>(
          create: (_) => mockBookService,
          child: MyApp(),
        ),
      );

      await tester.tap(find.text('Test Book'));
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('Test if long description is scrollable', (WidgetTester tester) async {
      final longDescription = 'A' * 4001;
      when(mockBookService.getBooks()).thenAnswer((_) async => [
        Book(title: 'Test Book', author: 'Test Author', isbn: '1234567890123', description: longDescription),
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<BookService>(
          create: (_) => mockBookService,
          child: MyApp(),
        ),
      );

      await tester.tap(find.text('Test Book'));
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailsScreen), findsOneWidget);
      expect(find.text(longDescription), findsOneWidget);

      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);

      final scrollable = tester.widget<SingleChildScrollView>(scrollableFinder);
      expect(scrollable.physics, isNotNull);
    });
  });
}
