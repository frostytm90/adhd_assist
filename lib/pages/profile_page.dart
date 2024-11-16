// pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDarkTheme = false;
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _remindersEnabled = prefs.getBool('remindersEnabled') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _isDarkTheme);
    prefs.setBool('remindersEnabled', _remindersEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Dark Theme'),
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                  _savePreferences();
                });
              },
            ),
            SwitchListTile(
              title: const Text('Reminders Enabled'),
              value: _remindersEnabled,
              onChanged: (value) {
                setState(() {
                  _remindersEnabled = value;
                  _savePreferences();
                });
              },
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Task Summary',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0),
            // Placeholder for task summary (future implementation)
            const Text('Completed Tasks: 0\nRemaining Tasks: 0'),
          ],
        ),
      ),
    );
  }
}
