
import 'package:flutter/material.dart';
import 'package:kyros/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Enable Dynamic Color'),
                subtitle: const Text(
                    'Uses your device\'s color scheme (Android 12+).'),
                value: themeProvider.isDynamic,
                onChanged: (bool value) {
                  themeProvider.toggleDynamicColor();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
