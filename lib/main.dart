
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
    ref.read(settingsProvider.notifier).initializeSettings();
    return MaterialApp.router(
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.appRouter,
    );
  }
}
