
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

enum SnackBarType { success, error, warning, info }

OverlayEntry? _previousSnackBar;

/// Shows a custom snackbar with a title and a message, and a color based on the type
/// 
/// The snackbar will be shown at the bottom of the screen and will be removed after the duration
/// 
/// Parameters:
/// - [context] is the [BuildContext] of the widget that called the function
/// - [type] is the type of the snackbar, which will determine the color
/// - [title] is the title of the snackbar
/// - [message] is the message of the snackbar
/// - [duration] is the duration the snackbar will be shown as a [Duration]. The default value
///     is 4 seconds
void showCustomSnackBar(
  BuildContext context, {
  required SnackBarType type,
  required String title,
  required String message,
  Duration duration = const Duration(seconds: 4)
}) {
  final OverlayEntry snackBar = OverlayEntry(
    builder: (_) => CustomSnackBar(
      type: type,
      title: title,
      message: message,
      duration: duration
    ),
  );

  // If there is a snackbar already shown, remove it
  if (_previousSnackBar != null && _previousSnackBar!.mounted) {
    _previousSnackBar!.remove();
  }

  // Insert the new snackbar and save it to remove it later
  Overlay.of(context).insert(snackBar);
  _previousSnackBar = snackBar;
}

class CustomSnackBar extends StatefulWidget {
  /// A custom snackbar that will be shown at the bottom of the screen
  /// 
  /// The snackbar contains a title and a message, and a color based on the type,
  /// the colors for each type must be defined in the [SnackBarTheme] via its
  /// declaration in a [ThemeData] extension
  /// 
  /// Parameters:
  /// - [type] is the type of the snackbar, which will determine the color
  /// - [title] is the title of the snackbar
  /// - [message] is the message of the snackbar
  /// - [duration] is the duration the snackbar will be shown as a [Duration]
  const CustomSnackBar({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    required this.duration
  });

  // Class attributes
  final SnackBarType type;
  final String title;
  final String message;
  final Duration duration;

  @override
  State<CustomSnackBar> createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> with TickerProviderStateMixin {
  late AnimationController _slideInController;
  late AnimationController _slideOutController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideInAnimation;
  late Animation<Offset> _slideOutAnimation;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    // Entry slide in animation
    _slideInController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _slideInAnimation = Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
      .animate(CurvedAnimation(parent: _slideInController, curve: Curves.elasticOut));

    // Exit slide out animation
    _slideOutController = AnimationController(duration: const Duration(milliseconds: 1750), vsync: this);
    _slideOutAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0))
      .animate(CurvedAnimation(parent: _slideOutController, curve: Curves.fastEaseInToSlowEaseOut));

    // Fade animation
    _fadeController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _fadeController, curve: Curves.linearToEaseOut));

    // Start the entry animation
    _slideInController.forward();
    _fadeController.forward();

    // After the entry animation is completed, wait for the duration and start the exit animation.
    // Ensuring the widget is removed from the tree after the exit animation is completed
    _slideInController.addStatusListener((status) {
      if (mounted && status == AnimationStatus.completed) {
        Future.delayed(widget.duration).then((_) => _dismissSnackBar());
      }
    });
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _slideOutController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Dismisses the snackbar by starting the exit animation
  /// 
  /// The exit animation will slide the snackbar out of the screen and fade it out
  void _dismissSnackBar() {
    if (mounted) {
      setState(() => _isClosing = true);
      _slideOutController.forward();
      _fadeController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final snackBarColors = theme.extension<SnackBarTheme>()!;
    Color snackBarColor;

    // Determine the color of the snackbar based on the type
    switch (widget.type) {
      case SnackBarType.success:
        snackBarColor = snackBarColors.success;
        break;
      case SnackBarType.error:
        snackBarColor = snackBarColors.error;
        break;
      case SnackBarType.warning:
        snackBarColor = snackBarColors.warning;
        break;
      case SnackBarType.info:
        snackBarColor = snackBarColors.info;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.bottomCenter,
      child: SlideTransition(
        position: _isClosing ? _slideOutAnimation : _slideInAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // SnackBar content
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: snackBarColor,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: textTheme.titleLarge!.copyWith(color: Colors.white),
                      ),
                      Text(
                        widget.message,
                        style: textTheme.titleSmall!.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Dismiss button
                Positioned(
                  right: 10, top: 10,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _dismissSnackBar,
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
