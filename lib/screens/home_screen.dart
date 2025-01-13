import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/book_list_item.dart';
import 'package:get_it/get_it.dart';
import 'settings_screen.dart';
import 'dart:async';

enum FilterType {
  none,
  category,
  author,
  rating
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = GetIt.I<BookService>();
  Stream<List<Book>>? _booksStream;
  String _searchQuery = '';
  FilterType _currentFilter = FilterType.none;
  String? _selectedCategory;
  String? _selectedAuthor;
  double? _selectedRating;

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

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            width: 300, // Fixed width for better visibility
            child: Column(
              mainAxisSize: MainAxisSize.min, // Take minimum required space
              children: [
                Text(
                  'Filter Books',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        RadioListTile<FilterType>(
                          title: Text('No Filter'),
                          value: FilterType.none,
                          groupValue: _currentFilter,
                          onChanged: (FilterType? value) {
                            setState(() {
                              _currentFilter = value!;
                              _selectedCategory = null;
                              _selectedAuthor = null;
                              _selectedRating = null;
                            });
                          },
                        ),
                        RadioListTile<FilterType>(
                          title: Text('Category'),
                          value: FilterType.category,
                          groupValue: _currentFilter,
                          onChanged: (FilterType? value) {
                            setState(() => _currentFilter = value!);
                            Navigator.pop(context);
                            _showCategorySelectionDialog();
                          },
                        ),
                        RadioListTile<FilterType>(
                          title: Text('Author'),
                          value: FilterType.author,
                          groupValue: _currentFilter,
                          onChanged: (FilterType? value) {
                            setState(() => _currentFilter = value!);
                            Navigator.pop(context);
                            _showAuthorSelectionDialog();
                          },
                        ),
                        RadioListTile<FilterType>(
                          title: Text('Rating'),
                          value: FilterType.rating,
                          groupValue: _currentFilter,
                          onChanged: (FilterType? value) {
                            setState(() => _currentFilter = value!);
                            Navigator.pop(context);
                            _showRatingSelectionDialog();
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  child: Text('Apply'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategorySelectionDialog() async {
    final books = await _bookService.getBooks();
    final categories = books
        .map((book) => book.category)
        .where((category) => category != null)
        .toSet()
        .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: SingleChildScrollView(
            child: Column(
              children: categories.map((category) =>
                ListTile(
                  title: Text(category ?? ''),
                  onTap: () {
                    setState(() => _selectedCategory = category?.isEmpty ?? true ? 'None' : category);
                    Navigator.pop(context);
                  },
                ),
              ).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showAuthorSelectionDialog() async {
    final books = await _bookService.getBooks();
    final authors = books
        .map((book) => book.author)
        .toSet()
        .toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Author'),
          content: SingleChildScrollView(
            child: Column(
              children: authors.map((author) =>
                ListTile(
                  title: Text(author),
                  onTap: () {
                    setState(() => _selectedAuthor = author);
                    Navigator.pop(context);
                  },
                ),
              ).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showRatingSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16.0),
            width: 300, // Fixed width for better visibility
            child: Column(
              mainAxisSize: MainAxisSize.min, // Will take minimum required space
              children: [
                Text(
                  'Select Minimum Rating',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        Slider(
                          value: _selectedRating ?? 0,
                          min: 0,
                          max: 5,
                          divisions: 10,
                          label: (_selectedRating ?? 0).toString(),
                          onChanged: (value) {
                            setState(() => _selectedRating = value);
                          },
                        ),
                        Text(
                          'Rating: ${(_selectedRating ?? 0).toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _applyFilters() {
    _fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          if (_currentFilter != FilterType.none)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text(_getActiveFilterText()),
                onDeleted: () {
                  setState(() {
                    _currentFilter = FilterType.none;
                    _selectedCategory = null;
                    _selectedAuthor = null;
                    _selectedRating = null;
                    _applyFilters();
                  });
                },
              ),
            ),
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
                  var filteredBooks = snapshot.data!.where((book) {
                    bool matchesSearch = book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        book.author.toLowerCase().contains(_searchQuery.toLowerCase());
                    
                    bool matchesFilter = true;
                    if (_currentFilter == FilterType.category) {
                      matchesFilter = book.category == _selectedCategory;
                    } else if (_currentFilter == FilterType.author) {
                      matchesFilter = book.author == _selectedAuthor;
                    } else if (_currentFilter == FilterType.rating) {
                      matchesFilter = (book.myRating ?? 0) >= (_selectedRating ?? 0);
                    }

                    return matchesSearch && matchesFilter;
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

  String _getActiveFilterText() {
    switch (_currentFilter) {
      case FilterType.category:
        return 'Category: $_selectedCategory';
      case FilterType.author:
        return 'Author: $_selectedAuthor';
      case FilterType.rating:
        return 'Rating: ≥ $_selectedRating';
      default:
        return '';
    }
  }
}
