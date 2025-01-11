import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/book.dart';
import 'package:my_app/services/book_service.dart';
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/screens/add_book_screen.dart';
import 'package:my_app/screens/settings_screen.dart';
import 'package:my_app/screens/book_details_screen.dart';

@GenerateMocks([BookService])
void main() {
  group('Widget Tests', () {
    late MockBookService mockBookService;

    setUp(() {
      mockBookService = MockBookService();
    });

    testWidgets('Test changing tabs and opening new screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<BookService>(
          create: (_) => mockBookService,
          child: MyApp(),
        ),
      );

      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(AddBookScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('Test adding a book and checking its existence', (WidgetTester tester) async {
      when(mockBookService.addBook(any)).thenAnswer((_) async => true);
      when(mockBookService.getBooks()).thenAnswer((_) async => [
        Book(title: 'Test Book', author: 'Test Author', isbn: '1234567890123'),
      ]);

      await tester.pumpWidget(
        ChangeNotifierProvider<BookService>(
          create: (_) => mockBookService,
          child: MyApp(),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('titleField')), 'Test Book');
      await tester.enterText(find.byKey(Key('authorField')), 'Test Author');
      await tester.enterText(find.byKey(Key('isbnField')), '1234567890123');
      await tester.tap(find.byKey(Key('submitButton')));
      await tester.pumpAndSettle();

      verify(mockBookService.addBook(any)).called(1);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      expect(find.text('Test Book'), findsOneWidget);
    });

    testWidgets('Test deleting a book', (WidgetTester tester) async {
      when(mockBookService.getBooks()).thenAnswer((_) async => [
        Book(title: 'Test Book', author: 'Test Author', isbn: '1234567890123'),
      ]);
      when(mockBookService.deleteBook(any)).thenAnswer((_) async => true);

      await tester.pumpWidget(
        ChangeNotifierProvider<BookService>(
          create: (_) => mockBookService,
          child: MyApp(),
        ),
      );

      await tester.tap(find.text('Test Book'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      verify(mockBookService.deleteBook('1234567890123')).called(1);
    });

    testWidgets('Test searching a book by ISBN and checking the result', (WidgetTester tester) async {
      when(mockBookService.searchBookByNameOrISBN(any)).thenAnswer((_) async => Book(
        title: 'Harry Potter',
        author: 'J.K. Rowling',
        isbn: '9780590353427',
      ));

      await tester.pumpWidget(
        ChangeNotifierProvider<BookService>(
          create: (_) => mockBookService,
          child: MyApp(),
        ),
      );

      await tester.enterText(find.byKey(Key('searchField')), '9780590353427');
      await tester.tap(find.byKey(Key('searchButton')));
      await tester.pumpAndSettle();

      expect(find.text('Harry Potter'), findsOneWidget);
    });
  });
}
