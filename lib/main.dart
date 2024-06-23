
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/themes.dart';
import 'package:sync_lyrics/routes/router.dart';

void main() => runApp(const ProviderScope(child: MainApp()));

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: /* isDarkMode ? ThemeMode.dark : ThemeMode.light */ ThemeMode.light,
      routerConfig: AppRouter.appRouter,
    );
  }
}
