
import 'package:flutter/material.dart';

class CustomAppTheme extends ThemeExtension<CustomAppTheme> {
  /// Extends [ThemeData] to include custom colors
  /// 
  /// The custom colors defined are:
  /// - [element] is the color of the main elements of the app
  /// - [internalShadow] is the color of the internal shadows
  /// - [externalShadow] is the color of the external shadows
  /// - [selected] is the color of the selected elements
  /// - [buttons] is the secondary color for buttons
  /// - [error] is the color of the error elements
  const CustomAppTheme({
    required this.element,
    required this.internalShadow,
    required this.externalShadow,
    required this.selected,
    required this.buttons,
    required this.error,
  });

  // Class attributes
  final Color element;
  final Color internalShadow;
  final Color externalShadow;
  final Color selected;
  final Color buttons;
  final Color error;

  @override
  ThemeExtension<CustomAppTheme> copyWith({
    Color? element,
    Color? internalShadow,
    Color? externalShadow,
    Color? selected,
    Color? buttons,
    Color? error
  }) {
    // Return a new instance of the class with the new values
    return CustomAppTheme(
      element: element ?? this.element,
      internalShadow: internalShadow ?? this.internalShadow,
      externalShadow: externalShadow ?? this.externalShadow,
      selected: selected ?? this.selected,
      buttons: buttons ?? this.buttons,
      error: error ?? this.error
    );
  }

  @override
  ThemeExtension<CustomAppTheme> lerp(CustomAppTheme? other, double t) {
    // If the other object is not of the same type, return the current object
    if (other is! CustomAppTheme) return this;

    // Return a new instance of the class with the interpolated values
    return CustomAppTheme(
      element: Color.lerp(element, other.element, t)!,
      internalShadow: Color.lerp(internalShadow, other.internalShadow, t)!,
      externalShadow: Color.lerp(externalShadow, other.externalShadow, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      buttons: Color.lerp(buttons, other.buttons, t)!,
      error: Color.lerp(error, other.error, t)!
    );
  }
}
