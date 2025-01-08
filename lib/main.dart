import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/add_book_screen.dart';
import 'screens/settings_screen.dart';
import 'models/book.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  bool _isDarkTheme = false;
  Color _primaryColor = Colors.blue;
  Color _accentColor = Colors.amber;
  double _fontSize = 16.0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AddBookScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _primaryColor = Color(prefs.getInt('primaryColor') ?? Colors.blue.value);
      _accentColor = Color(prefs.getInt('accentColor') ?? Colors.amber.value);
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Tracker',
      theme: ThemeData(
        brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
        primaryColor: _primaryColor,
        accentColor: _accentColor,
        textTheme: TextTheme(
          bodyText1: TextStyle(fontSize: _fontSize),
          bodyText2: TextStyle(fontSize: _fontSize),
        ),
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
    );
  }
}
