
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

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  /// Initialize the settings provider with the local settings database
  void _initializeSettings() async {
    await ref.read(settingsProvider.notifier).initializeSettings();
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const CircularProgressIndicator();
    return MaterialApp.router(
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: /* isDarkMode ? ThemeMode.dark : ThemeMode.light */ ThemeMode.light,
      routerConfig: AppRouter.appRouter,
    );
  }
}
