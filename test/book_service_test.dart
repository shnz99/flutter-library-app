import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library_app/models/book.dart';
import 'package:flutter_library_app/services/book_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookService', () {
    late BookService bookService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      bookService = BookService();
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
