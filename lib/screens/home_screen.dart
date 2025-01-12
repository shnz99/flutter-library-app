import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/book_list_item.dart';
import 'package:get_it/get_it.dart';
import 'settings_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = GetIt.I<BookService>();
  Stream<List<Book>>? _booksStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  void _fetchBooks() {
    setState(() {
      _booksStream = _bookService.getBooksStreamSortedAlphabetically();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _fetchBooks();
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: _booksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No books found'));
                } else {
                  final filteredBooks = snapshot.data!.where((book) {
                    return book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        book.author.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: BookListItem(book: filteredBooks[index]),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title or author',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ],
      ),
    );
  }
}
