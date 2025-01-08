import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
      final books = booksJson.map((json) => Book.fromJson(json)).toList();
      books.sort((a, b) => a.title.compareTo(b.title));
      return books;
    }
    return [];
  }

  Future<List<Book>> getBooksSortedAlphabetically() async {
    final books = await getBooks();
    books.sort((a, b) => a.title.compareTo(b.title));
    return books;
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

  Future<void> addNotes(String isbn, String notes) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await getBooks();
    final index = books.indexWhere((b) => b.isbn == isbn);
    if (index != -1) {
      books[index].notes = notes;
      await prefs.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
    }
  }

  Future<void> updateReadingProgress(String isbn, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await getBooks();
    final index = books.indexWhere((b) => b.isbn == isbn);
    if (index != -1) {
      books[index].readingProgress = progress;
      await prefs.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
    }
  }

  Future<void> rateBook(String isbn, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    final books = await getBooks();
    final index = books.indexWhere((b) => b.isbn == isbn);
    if (index != -1) {
      books[index].rating = rating;
      await prefs.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
    }
  }

  Future<Book?> searchBookByNameOrISBN(String query) async {
    final url = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['totalItems'] > 0) {
        final bookData = data['items'][0]['volumeInfo'];
        return Book(
          title: bookData['title'] ?? '',
          author: bookData['authors']?.join(', ') ?? '',
          isbn: bookData['industryIdentifiers']?.firstWhere((id) => id['type'] == 'ISBN_13', orElse: () => null)?['identifier'] ?? '',
          notes: '',
          rating: 0.0,
          readingProgress: 0.0,
        );
      }
    }
    return null;
  }
}
