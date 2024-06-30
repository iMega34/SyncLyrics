
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Open a dialog with a custom child widget
/// 
/// The opening and closing animations ressemble the Cupertino dialog, with a fade in and scale effect,
/// however, the dialog is set to be dismissible by pressing the escape key. The dialog is wrapped in a
/// `ScaffoldMessenger` to allow the implementation with a custom SnackBar widget.
///
/// Parameters:
/// - [context] is the current build context
/// - [child] is the widget to be displayed within the dialog
void openDialog(BuildContext context, {required Widget child}) {
  final dialogScaleTween = Tween<double>(begin: 1.3, end: 1.0)
    .chain(CurveTween(curve: Curves.linearToEaseOut));
  // Used the `showGeneralDialog` method to display a generic dialog, hence the custom animations
  // and the callback shortcuts to close the dialog with the escape key
  showGeneralDialog(
    context: context,
    barrierLabel: "",
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => ScaffoldMessenger(
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: CallbackShortcuts(
            // Close the dialog when the escape key is pressed
            bindings: { const SingleActivator(LogicalKeyboardKey.escape) : () => Navigator.pop(context) },
            child: child
          )
        )
      ),
    ),
    transitionBuilder: (_, animation, __, child) {
      final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
      // If the dialog is closing, fade out only the content
      if (animation.status == AnimationStatus.reverse) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: child
        );
      }
      // Otherwise, fade out the content and scale the dialog
      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: animation.drive(dialogScaleTween),
          child: child,
        ),
      );
    },
  );
}
