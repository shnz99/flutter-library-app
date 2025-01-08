import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = false;
  Color _primaryColor = Colors.blue;
  Color _accentColor = Colors.amber;
  double _fontSize = 16.0;
  bool _isGridView = false;
  double _spacing = 8.0;
  double _padding = 8.0;
  bool _isHighContrast = false;
  double _textToSpeechSpeed = 1.0;
  double _textToSpeechPitch = 1.0;

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
      _isGridView = prefs.getBool('isGridView') ?? false;
      _spacing = prefs.getDouble('spacing') ?? 8.0;
      _padding = prefs.getDouble('padding') ?? 8.0;
      _isHighContrast = prefs.getBool('isHighContrast') ?? false;
      _textToSpeechSpeed = prefs.getDouble('textToSpeechSpeed') ?? 1.0;
      _textToSpeechPitch = prefs.getDouble('textToSpeechPitch') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDarkTheme);
    await prefs.setInt('primaryColor', _primaryColor.value);
    await prefs.setInt('accentColor', _accentColor.value);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setBool('isGridView', _isGridView);
    await prefs.setDouble('spacing', _spacing);
    await prefs.setDouble('padding', _padding);
    await prefs.setBool('isHighContrast', _isHighContrast);
    await prefs.setDouble('textToSpeechSpeed', _textToSpeechSpeed);
    await prefs.setDouble('textToSpeechPitch', _textToSpeechPitch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          SwitchListTile(
            title: Text('Dark Theme'),
            value: _isDarkTheme,
            onChanged: (bool value) {
              setState(() {
                _isDarkTheme = value;
              });
              _saveSettings();
              _applySettings();
            },
          ),
          ListTile(
            title: Text('Primary Color'),
            trailing: CircleAvatar(
              backgroundColor: _primaryColor,
            ),
            onTap: () {
              _pickColor(context, 'Primary Color', _primaryColor, (color) {
                setState(() {
                  _primaryColor = color;
                });
                _saveSettings();
                _applySettings();
              });
            },
          ),
          ListTile(
            title: Text('Accent Color'),
            trailing: CircleAvatar(
              backgroundColor: _accentColor,
            ),
            onTap: () {
              _pickColor(context, 'Accent Color', _accentColor, (color) {
                setState(() {
                  _accentColor = color;
                });
                _saveSettings();
                _applySettings();
              });
            },
          ),
          ListTile(
            title: Text('Font Size'),
            subtitle: Slider(
              value: _fontSize,
              min: 12.0,
              max: 24.0,
              onChanged: (double value) {
                setState(() {
                  _fontSize = value;
                });
                _saveSettings();
                _applySettings();
              },
            ),
          ),
          SwitchListTile(
            title: Text('Grid View'),
            value: _isGridView,
            onChanged: (bool value) {
              setState(() {
                _isGridView = value;
              });
              _saveSettings();
              _applySettings();
            },
          ),
          ListTile(
            title: Text('Spacing'),
            subtitle: Slider(
              value: _spacing,
              min: 0.0,
              max: 16.0,
              onChanged: (double value) {
                setState(() {
                  _spacing = value;
                });
                _saveSettings();
                _applySettings();
              },
            ),
          ),
          ListTile(
            title: Text('Padding'),
            subtitle: Slider(
              value: _padding,
              min: 0.0,
              max: 16.0,
              onChanged: (double value) {
                setState(() {
                  _padding = value;
                });
                _saveSettings();
                _applySettings();
              },
            ),
          ),
          SwitchListTile(
            title: Text('High Contrast Mode'),
            value: _isHighContrast,
            onChanged: (bool value) {
              setState(() {
                _isHighContrast = value;
              });
              _saveSettings();
              _applySettings();
            },
          ),
          ListTile(
            title: Text('Text-to-Speech Speed'),
            subtitle: Slider(
              value: _textToSpeechSpeed,
              min: 0.5,
              max: 2.0,
              onChanged: (double value) {
                setState(() {
                  _textToSpeechSpeed = value;
                });
                _saveSettings();
                _applySettings();
              },
            ),
          ),
          ListTile(
            title: Text('Text-to-Speech Pitch'),
            subtitle: Slider(
              value: _textToSpeechPitch,
              min: 0.5,
              max: 2.0,
              onChanged: (double value) {
                setState(() {
                  _textToSpeechPitch = value;
                });
                _saveSettings();
                _applySettings();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context, String title, Color currentColor, ValueChanged<Color> onColorPicked) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: onColorPicked,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _applySettings() {
    final theme = ThemeData(
      brightness: _isDarkTheme ? Brightness.dark : Brightness.light,
      primaryColor: _primaryColor,
      accentColor: _accentColor,
      textTheme: TextTheme(
        bodyText1: TextStyle(fontSize: _fontSize),
        bodyText2: TextStyle(fontSize: _fontSize),
      ),
    );

    // Apply the theme to the app
    final appState = context.findAncestorStateOfType<_MyAppState>();
    appState?.setTheme(theme);
  }
}
