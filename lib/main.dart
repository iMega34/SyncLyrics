
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sync_lyrics/themes.dart';
import 'package:sync_lyrics/routes/router.dart';
import 'package:sync_lyrics/providers/settings_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(settingsProvider.notifier).initializeSettings(),
      builder: (context, snapshot) {
        // Show loading spinner while waiting for settings to be loaded
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Show error message if settings failed to load
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        // Show the app once settings are loaded successfully
        return MaterialApp.router(
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: ThemeMode.light,
          routerConfig: AppRouter.appRouter,
        );
      },
    );
  }
}
