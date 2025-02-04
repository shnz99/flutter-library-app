import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publishedDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _myRatingController = TextEditingController();
  final _categoryController = TextEditingController();
  final _readDateController = TextEditingController();
  final _notesController = TextEditingController();
  final BookService _bookService = GetIt.I<BookService>();
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.book.title;
    _authorController.text = widget.book.author;
    _isbnController.text = widget.book.isbn;
    _publishedDateController.text = widget.book.publishedDate?.toString() ?? '';
    _descriptionController.text = widget.book.description ?? '';
    _myRatingController.text = widget.book.myRating?.toString() ?? '';
    _categoryController.text = widget.book.category ?? '';
    _readDateController.text = widget.book.readDate != null
        ? '${widget.book.readDate!.month.toString().padLeft(2, '0')}-${widget.book.readDate!.year.toString().padLeft(4, '0')}'
        : '';
    _notesController.text = widget.book.notes ?? '';
    _imageUrl = widget.book.imageUrl;
    _readDateController.addListener(_formatReadDate);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _publishedDateController.dispose();
    _descriptionController.dispose();
    _myRatingController.dispose();
    _categoryController.dispose();
    _readDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _formatReadDate() {
    final text = _readDateController.text;
    if (text.length == 2 && !text.contains('-')) {
      _readDateController.text = '$text-';
      _readDateController.selection = TextSelection.fromPosition(TextPosition(offset: _readDateController.text.length));
    }
  }

  void _searchForBook() async {
    final query = _isbnController.text.isNotEmpty ? _isbnController.text : (_titleController.text.isNotEmpty ? _titleController.text : _authorController.text);
    if (query.isEmpty) {
      _showErrorMessage('Please enter a title, author, or ISBN');
      return;
    }

    try {
      final books = await _bookService.searchForBook(query);
      if (books.isNotEmpty) {
        _showBookSelectionDialog(books);
      } else {
        _showErrorMessage('No books found');
      }
    } catch (e) {
      _showErrorMessage('Failed to fetch book details');
    }
  }

  void _showBookSelectionDialog(List<Book> books) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Book'),
          content: SingleChildScrollView(
            child: Column(
              children: books.map((book) {
                return ListTile(
                  leading: book.imageUrl != null
                      ? Image.network(book.imageUrl!)
                      : Image.asset('assets/images/placeholder.png'),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () {
                    setState(() {
                      _titleController.text = book.title;
                      _authorController.text = book.author;
                      _isbnController.text = book.isbn;
                      _publishedDateController.text = book.publishedDate?.toString() ?? '';
                      _descriptionController.text = book.description ?? '';
                      _imageUrl = book.imageUrl;
                    });
                    Navigator.pop(context);
                    _showSuccessMessage('Book details updated successfully!');
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedBook = Book(
        title: _titleController.text,
        author: _authorController.text,
        isbn: _isbnController.text,
        imageUrl: _imageUrl,
        publishedDate: int.tryParse(_publishedDateController.text),
        description: _descriptionController.text,
        myRating: double.tryParse(_myRatingController.text),
        category: _categoryController.text,
        readDate: _readDateController.text.isNotEmpty ? DateTime.parse('${_readDateController.text.split('-')[1]}-${_readDateController.text.split('-')[0]}-01') : null,
        notes: _notesController.text,
      );
      try {
        await _bookService.updateBook(updatedBook);
        _showSuccessMessage('Book updated successfully!');
        Navigator.pop(context);
      } catch (e) {
        _showErrorMessage('Failed to update book');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter the book title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _authorController,
                  decoration: InputDecoration(labelText: 'Author'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter the author';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _isbnController,
                  decoration: InputDecoration(labelText: 'ISBN'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter the ISBN';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _publishedDateController,
                  decoration: InputDecoration(labelText: 'Published Date'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _readDateController,
                  decoration: InputDecoration(labelText: 'Read Date (MM-YYYY)'),
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final parts = value.split('-');
                      if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 4) {
                        return 'Please enter a valid date (MM-YYYY)';
                      }
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(labelText: 'Notes'),
                ),
                RatingBar.builder(
                  initialRating: widget.book.myRating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    _myRatingController.text = rating.toString();
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _searchForBook,
                        child: Text('Search for Book'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveBook,
                        child: Text('Save'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Discard'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
