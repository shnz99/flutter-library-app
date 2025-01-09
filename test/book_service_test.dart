import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library_app/models/book.dart';
import 'package:flutter_library_app/services/book_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookService', () {
    late BookService bookService;
    late Database db;

    setUp(() async {
      db = await openDatabase(
        join(await getDatabasesPath(), 'test_books_database.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE books(isbn TEXT PRIMARY KEY, title TEXT, author TEXT, imageUrl TEXT, publishedDate INTEGER, description TEXT)',
          );
        },
        version: 1,
      );
      bookService = BookService();
      bookService.initDatabase();
    });

    tearDown(() async {
      await db.close();
      final path = join(await getDatabasesPath(), 'test_books_database.db');
      await deleteDatabase(path);
    });

    test('add two books, remove one, and check if the other is present', () async {
      final book1 = Book(
        title: 'Book One',
        author: 'Author One',
        isbn: '1234567890123',
      );

      final book2 = Book(
        title: 'Book Two',
        author: 'Author Two',
        isbn: '9876543210987',
      );

      await bookService.addBook(book1);
      await bookService.addBook(book2);

      var books = await bookService.getBooks();
      expect(books.length, 2);

      await bookService.deleteBook('1234567890123');

      books = await bookService.getBooks();
      expect(books.length, 1);
      expect(books[0].isbn, '9876543210987');
    });
  });
}
