import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Simple settings screen — not the focus of the assignment,
// kept intentionally lightweight per the requirements.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local-only toggle for this screen. Wiring this to a real app-wide
  // dark theme would require lifting state up to main.dart with a
  // ValueNotifier or similar — left as a visual placeholder here since
  // the assignment says not to spend much time on Settings.
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
            title: const Text('Theme'),
            subtitle: Text(_darkMode ? 'Dark' : 'Light'),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6_outlined, color: AppTheme.primaryColor),
            title: const Text('Change Theme'),
            subtitle: const Text('Light / Dark'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme switching is a visual demo in this build.'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
            title: const Text('About App'),
            subtitle: const Text('Contact Management App — local SQLite storage'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Contact Management App',
                applicationVersion: '1.0.0',
                children: const [
                  Text(
                    'A simple Flutter app for managing contacts locally using SQLite. '
                    'No backend or internet connection required.',
                  ),
                ],
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.numbers, color: AppTheme.primaryColor),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}