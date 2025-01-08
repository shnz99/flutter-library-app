import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library_app/models/book.dart';
import 'package:flutter_library_app/services/book_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookService', () {
    late BookService bookService;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      bookService = BookService();
    });

    test('addBook adds a book to the library', () async {
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        isbn: '1234567890',
        notes: 'Test notes',
        rating: 4.5,
        readingProgress: 0.75,
      );
      await bookService.addBook(book);

      final books = await bookService.getBooks();
      expect(books.length, 1);
      expect(books.first.title, 'Test Book');
      expect(books.first.author, 'Test Author');
      expect(books.first.isbn, '1234567890');
      expect(books.first.notes, 'Test notes');
      expect(books.first.rating, 4.5);
      expect(books.first.readingProgress, 0.75);
    });

    test('updateBook updates a book in the library', () async {
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        isbn: '1234567890',
        notes: 'Test notes',
        rating: 4.5,
        readingProgress: 0.75,
      );
      await bookService.addBook(book);

      final updatedBook = Book(
        title: 'Updated Book',
        author: 'Updated Author',
        isbn: '1234567890',
        notes: 'Updated notes',
        rating: 5.0,
        readingProgress: 1.0,
      );
      await bookService.updateBook(updatedBook);

      final books = await bookService.getBooks();
      expect(books.length, 1);
      expect(books.first.title, 'Updated Book');
      expect(books.first.author, 'Updated Author');
      expect(books.first.isbn, '1234567890');
      expect(books.first.notes, 'Updated notes');
      expect(books.first.rating, 5.0);
      expect(books.first.readingProgress, 1.0);
    });

    test('deleteBook removes a book from the library', () async {
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        isbn: '1234567890',
        notes: 'Test notes',
        rating: 4.5,
        readingProgress: 0.75,
      );
      await bookService.addBook(book);

      await bookService.deleteBook('1234567890');

      final books = await bookService.getBooks();
      expect(books.length, 0);
    });

    test('getBooks returns all books in the library', () async {
      final book1 = Book(
        title: 'Test Book 1',
        author: 'Test Author 1',
        isbn: '1234567890',
        notes: 'Test notes 1',
        rating: 4.5,
        readingProgress: 0.75,
      );
      final book2 = Book(
        title: 'Test Book 2',
        author: 'Test Author 2',
        isbn: '0987654321',
        notes: 'Test notes 2',
        rating: 5.0,
        readingProgress: 1.0,
      );
      await bookService.addBook(book1);
      await bookService.addBook(book2);

      final books = await bookService.getBooks();
      expect(books.length, 2);
      expect(books[0].title, 'Test Book 1');
      expect(books[1].title, 'Test Book 2');
    });

    test('addNotes adds notes to a book', () async {
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        isbn: '1234567890',
        notes: 'Test notes',
        rating: 4.5,
        readingProgress: 0.75,
      );
      await bookService.addBook(book);

      await bookService.addNotes('1234567890', 'Updated notes');

      final books = await bookService.getBooks();
      expect(books.first.notes, 'Updated notes');
    });

    test('updateReadingProgress updates the reading progress of a book', () async {
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        isbn: '1234567890',
        notes: 'Test notes',
        rating: 4.5,
        readingProgress: 0.75,
      );
      await bookService.addBook(book);

      await bookService.updateReadingProgress('1234567890', 0.5);

      final books = await bookService.getBooks();
      expect(books.first.readingProgress, 0.5);
    });

    test('rateBook updates the rating of a book', () async {
      final book = Book(
        title: 'Test Book',
        author: 'Test Author',
        isbn: '1234567890',
        notes: 'Test notes',
        rating: 4.5,
        readingProgress: 0.75,
      );
      await bookService.addBook(book);

      await bookService.rateBook('1234567890', 4.5);

      final books = await bookService.getBooks();
      expect(books.first.rating, 4.5);
    });
  });
}
