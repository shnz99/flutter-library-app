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
          'CREATE TABLE $_booksTable(isbn TEXT PRIMARY KEY, title TEXT, author TEXT, imageUrl TEXT, publishedDate INTEGER, description TEXT, myRating REAL, averageRating REAL, category TEXT, readDate TEXT, notes TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> addBook(Book book) async {
    final db = await database;
    final bookToAdd = book.category?.isEmpty ?? true ? book.copyWith(category: 'None') : book;
    await db.insert(
      _booksTable,
      bookToAdd.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notifyBookListChanged();
  }

  Future<void> updateBook(Book book) async {
    final db = await database;
    final bookToUpdate = book.category?.isEmpty ?? true ? book.copyWith(category: 'None') : book;
    await db.update(
      _booksTable,
      bookToUpdate.toMap(),
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
      final book = Book.fromMap(maps[i]);
      return book.category?.isEmpty ?? true ? book.copyWith(category: 'None') : book;
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
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(_booksTable);
      final List<Book> books = List.generate(maps.length, (i) => Book.fromMap(maps[i]));
      final String jsonData = jsonEncode(books.map((book) => book.toMap()).toList());
      
      final File file = File(filePath);
      await file.writeAsString(jsonData);
    } catch (e) {
      throw Exception('Failed to export library: $e');
    }
  }

  Future<void> importLibrary(String filePath) async {
    try {
      final File file = File(filePath);
      final String jsonData = await file.readAsString();
      final List<dynamic> booksJson = jsonDecode(jsonData);
      
      final Database db = await database;
      await db.transaction((txn) async {
        await txn.delete(_booksTable);
        
        for (var bookJson in booksJson) {
          final Book book = Book.fromMap(bookJson as Map<String, dynamic>);
          await txn.insert(
            _booksTable,
            book.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      
      _notifyBookListChanged();
    } catch (e) {
      throw Exception('Failed to import library: $e');
    }
  }

  Future<List<Book>> searchForBook(String query) async {
    final isISBN13 = RegExp(r'^\d{13}$').hasMatch(query);
    final isISBN10 = RegExp(r'^\d{10}$').hasMatch(query);

    final url = isISBN13
        ? Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$query')
        : isISBN10
            ? Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn10:$query')
            : Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$query');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['totalItems'] > 0) {
        final List<Book> books = [];
        for (var item in data['items']) {
          final bookData = item['volumeInfo'];
          books.add(Book(
            title: bookData['title'] ?? '',
            author: bookData['authors']?.join(', ') ?? '',
            isbn: bookData['industryIdentifiers']?.firstWhere((id) => id['type'] == 'ISBN_13', orElse: () => null)?['identifier'] ?? '',
            imageUrl: bookData['imageLinks']?['thumbnail'], // Pba27
            publishedDate: int.tryParse(bookData['publishedDate']?.split('-')?.first ?? ''),
            description: bookData['description'] ?? '',
            averageRating: bookData['averageRating']?.toDouble(),
            category: bookData['categories']?.join(', ') ?? '',
            readDate: bookData['readDate'] != null ? DateTime.parse(bookData['readDate']) : null,
            notes: bookData['notes'] ?? '',
          ));
        }
        return books;
      } else {
        throw Exception('No books found');
      }
    } else {
      throw Exception('Failed to fetch book details');
    }
  }

  void _notifyBookListChanged() async {
    final books = await getBooksSortedAlphabetically();
    _booksStreamController.add(books);
  }
}
