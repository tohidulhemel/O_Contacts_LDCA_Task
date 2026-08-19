import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, themeMode, _) {
          final isDark = themeMode == ThemeMode.dark;

          return ListView(
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
                title: const Text('Theme'),
                subtitle: Text(isDark ? 'Dark' : 'Light'),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.brightness_6_outlined, color: AppTheme.primaryColor),
                title: const Text('Change Theme'),
                subtitle: const Text('Light / Dark'),
                value: isDark,
                onChanged: (value) {
                  themeModeNotifier.value =
                      value ? ThemeMode.dark : ThemeMode.light;
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
          );
        },
      ),
    );
  }
}