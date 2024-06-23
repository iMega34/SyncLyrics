
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sync_lyrics/screens/sidebar.dart';
import 'package:sync_lyrics/screens/settings.dart';
import 'package:sync_lyrics/screens/lyric_generator.dart';

/// Class containing the router used by the app to navigate between screens
/// 
/// The router is defined using the `GoRouter` package, and implements the functionality
/// to change the screen based on the index of the sidebar item and the transition animation
class AppRouter {
  /// Main router configuration
  /// 
  /// This is where all the routes are defined
  /// 
  /// The `ShellRoute` is used to define a layout that will be used by all the routes, meaning
  /// that all the routes will be rendered inside the `Scaffold` widget defined in the `ShellRoute`,
  /// making it possible to have a sidebar that is shared by all the routes.
  static final appRouter = GoRouter(
    routes: [
      ShellRoute(
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LyricsGeneratorScreen(),
              transitionsBuilder: (_, animation, __, child) => _screenTransition(animation, child),
            )
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: (_, animation, __, child) => _screenTransition(animation, child),
            )
          ),
        ],
        builder: (context, state, child) => Scaffold(
          body: Row(
            children: [
              const Sidebar(),
              const VerticalDivider(),
              Expanded(child: child),
            ],
          ),
        ),
      )
    ]
  );

  /// Helper function to create a screen transition
  /// 
  /// Consists in a slide transition that slides from the bottom to the top
  /// 
  /// Parameters:
  /// - [animation] is the animation controller
  /// - [child] is the widget to be animated
  static Widget _screenTransition(Animation<double> animation, Widget child) {
    final position = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero
    );
    final offsetTransition = CurvedAnimation(
      parent: animation,
      curve: Curves.fastLinearToSlowEaseIn
    );
    return SlideTransition(
      position: position.animate(offsetTransition),
      child: child,
    );
  }

  /// Change screen based on the index
  /// 
  /// Used by the sidebar to change the screen based on the index of the sidebar item
  /// 
  /// Parameters:
  /// - [context] is the current context
  /// - [index] is the index of the sidebar item
  static changeScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/settings');
        break;
    }
  }
}
