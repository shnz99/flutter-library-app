import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_book_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/book_details_screen.dart'; // Import the new screen
import 'screens/edit_book_screen.dart'; // Import the EditBookScreen
import 'models/book.dart'; // Import the Book class
import 'services/book_service.dart'; // Import the BookService class
import 'package:get_it/get_it.dart';

void main() {
  GetIt.I.registerSingleton<BookService>(BookService());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  final BookService _bookService = GetIt.I<BookService>();

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AddBookScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _initializeDatabase() async {
    await _bookService.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Tracker',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
      routes: {
        '/bookDetails': (context) => BookDetailsScreen(book: ModalRoute.of(context)!.settings.arguments as Book),
        '/editBook': (context) => EditBookScreen(book: ModalRoute.of(context)!.settings.arguments as Book),
      },
    );
  }
}
