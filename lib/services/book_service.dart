import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class BookService {
  static const String _booksKey = 'books';

  Future<void> addBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await getBooks();
    books.add(book);
    await prefs.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
  }

  Future<void> updateBook(Book book) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await getBooks();
    final index = books.indexWhere((b) => b.isbn == book.isbn);
    if (index != -1) {
      books[index] = book;
      await prefs.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
    }
  }

  Future<void> deleteBook(String isbn) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await getBooks();
    books.removeWhere((b) => b.isbn == isbn);
    await prefs.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
  }

  Future<List<Book>> getBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksString = prefs.getString(_booksKey);
    if (booksString != null) {
      final List<dynamic> booksJson = jsonDecode(booksString);
      return booksJson.map((json) => Book.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> exportLibrary(String filePath) async {
    final books = await getBooks();
    final file = File(filePath);
    await file.writeAsString(jsonEncode(books.map((b) => b.toJson()).toList()));
  }

  Future<void> importLibrary(String filePath) async {
    final file = File(filePath);
    final booksString = await file.readAsString();
    final List<dynamic> booksJson = jsonDecode(booksString);
    final books = booksJson.map((json) => Book.fromJson(json)).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
  }
}
