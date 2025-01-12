import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';

class BookService {
  static const String _booksTable = 'books';
  static Database? _database;
  static final BookService _instance = BookService._internal();
  final StreamController<List<Book>> _booksStreamController = StreamController<List<Book>>.broadcast();

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
          'CREATE TABLE $_booksTable(isbn TEXT PRIMARY KEY, title TEXT, author TEXT, imageUrl TEXT, publishedDate INTEGER, description TEXT, myRating REAL, averageRating REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> addBook(Book book) async {
    final db = await database;
    await db.insert(
      _booksTable,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyBookListChanged();
  }

  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update(
      _booksTable,
      book.toMap(),
      where: 'isbn = ?',
      whereArgs: [book.isbn],
    );
    _notifyBookListChanged();
  }

  Future<void> deleteBook(String isbn) async {
    final db = await database;
    await db.delete(
      _booksTable,
      where: 'isbn = ?',
      whereArgs: [isbn],
    );
    _notifyBookListChanged();
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_booksTable);

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<List<Book>> getBooksSortedAlphabetically() async {
    final books = await getBooks();
    books.sort((a, b) => a.title.compareTo(b.title));
    return books;
  }

  Stream<List<Book>> getBooksStreamSortedAlphabetically() {
    _notifyBookListChanged();
    return _booksStreamController.stream;
  }

  Future<void> exportLibrary(String filePath) async {
    try {
      final books = await getBooks();
      final file = File(filePath);
      final sqlDump = StringBuffer();

      sqlDump.writeln('BEGIN TRANSACTION;');
      for (var book in books) {
        sqlDump.writeln(
          "INSERT INTO $_booksTable (isbn, title, author, imageUrl, publishedDate, description, myRating, averageRating) VALUES ('${book.isbn}', '${book.title}', '${book.author}', '${book.imageUrl}', ${book.publishedDate}, '${book.description}', ${book.myRating}, ${book.averageRating});"
        );
      }
      sqlDump.writeln('COMMIT;');

      await file.writeAsString(sqlDump.toString());
    } catch (e) {
      throw Exception('Failed to export library: $e');
    }
  }

  Future<void> importLibrary(String filePath) async {
    try {
      final file = File(filePath);
      final sqlDump = await file.readAsString();
      final db = await database;
      await db.execute('BEGIN TRANSACTION;');
      await db.execute(sqlDump);
      await db.execute('COMMIT;');
      _notifyBookListChanged();
    } catch (e) {
      throw Exception('Failed to import library: $e');
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
          publishedDate: int.tryParse(bookData['publishedDate']?.split('-')?.first ?? ''),
          description: bookData['description'] ?? '',
          averageRating: bookData['averageRating']?.toDouble(),
        );
      }
    }
    return null;
  }

  void _notifyBookListChanged() async {
    final books = await getBooksSortedAlphabetically();
    _booksStreamController.add(books);
  }
}
