import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_book_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/book_details_screen.dart'; // Import the new screen
import 'screens/edit_book_screen.dart'; // Import the EditBookScreen
import 'screens/statistics_screen.dart'; // Import the StatisticsScreen
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
    StatisticsScreen(), // Add the StatisticsScreen to the widget options
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
    _showLoadingScreen();
  }

  void _initializeDatabase() async {
    await _bookService.initDatabase();
  }

  void _showLoadingScreen() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Library',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: _selectedIndex == -1
          ? LoadingScreen()
          : Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mobile Library'),
                    FutureBuilder<int>(
                      future: _bookService.getBooksCount(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            '...',
                            style: TextStyle(fontSize: 14),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error',
                            style: TextStyle(fontSize: 14),
                          );
                        } else {
                          return Text(
                            'Total Books: ${snapshot.data}',
                            style: TextStyle(fontSize: 14),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
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
                    icon: Icon(Icons.bar_chart),
                    label: 'Statistics',
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

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/placeholder.png', width: 100, height: 100),
            SizedBox(height: 20),
            Text(
              'Mobile Library',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
