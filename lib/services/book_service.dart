import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class BookService {
  static const String _booksTable = 'books';
  static Database? _database;
  static final BookService _instance = BookService._internal();

  factory BookService() {
    return _instance;
  }

  BookService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'books_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE $_booksTable(isbn TEXT PRIMARY KEY, title TEXT, author TEXT, imageUrl TEXT, publishedDate INTEGER, description TEXT, isbn10 TEXT, myRating REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> addBook(Book book) async {
    final db = await database;
    await db.insert(
      _booksTable,
      book.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      _booksTable,
      book.toJson(),
      where: 'isbn = ?',
      whereArgs: [book.isbn],
    );
  }

  Future<void> deleteBook(String isbn) async {
    final db = await database;
    await db.delete(
      _booksTable,
      where: 'isbn = ?',
      whereArgs: [isbn],
    );
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_booksTable);

    return List.generate(maps.length, (i) {
      return Book(
        title: maps[i]['title'],
        author: maps[i]['author'],
        isbn: maps[i]['isbn'],
        isbn10: maps[i]['isbn10'],
        imageUrl: maps[i]['imageUrl'],
        publishedDate: maps[i]['publishedDate'],
        description: maps[i]['description'],
        myRating: maps[i]['myRating']?.toDouble(),
      );
    });
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
    final db = await database;
    for (var book in books) {
      await db.insert(
        _booksTable,
        book.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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
          isbn10: bookData['industryIdentifiers']?.firstWhere((id) => id['type'] == 'ISBN_10', orElse: () => null)?['identifier'] ?? '',
          publishedDate: int.tryParse(bookData['publishedDate']?.split('-')?.first ?? ''),
          description: bookData['description'] ?? '',
        );
      }
    }
    return null;
  }
}
