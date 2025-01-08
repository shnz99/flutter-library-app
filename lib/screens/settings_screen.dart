import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
}
