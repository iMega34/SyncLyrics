
import 'package:flutter/material.dart';

class CustomAppTheme extends ThemeExtension<CustomAppTheme> {
  /// Extends [ThemeData] to include custom colors
  /// 
  /// The custom colors defined are:
  /// - [element]: The color of the main elements of the app
  /// - [internalShadow]: The color of the internal shadows
  /// - [externalShadow]: The color of the external shadows
  /// - [accent]: The color of the accent elements
  /// - [error]: The color of the error elements
  const CustomAppTheme({
    required this.element,
    required this.internalShadow,
    required this.externalShadow,
    required this.accent,
    required this.error,
  });

  // Class attributes
  final Color element;
  final Color internalShadow;
  final Color externalShadow;
  final Color accent;
  final Color error;

  @override
  ThemeExtension<CustomAppTheme> copyWith({
    Color? element,
    Color? internalShadow,
    Color? externalShadow,
    Color? accent,
    Color? error
  }) {
    // Return a new instance of the class with the new values
    return CustomAppTheme(
      element: element ?? this.element,
      internalShadow: internalShadow ?? this.internalShadow,
      externalShadow: externalShadow ?? this.externalShadow,
      accent: accent ?? this.accent,
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
      accent: Color.lerp(accent, other.accent, t)!,
      error: Color.lerp(error, other.error, t)!
    );
  }
}
