
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

class CustomButtonTheme extends ThemeExtension<CustomButtonTheme> {
  /// Extends [ThemeData] to include custom button colors
  /// 
  /// The custom colors defined are:
  /// - [addLine] is the color of the add line button
  /// - [addSpace] is the color of the add space button
  /// - [removeLine] is the color of the remove line button
  /// - [moveLine] is the color of the move line button
  const CustomButtonTheme({
    required this.addLine,
    required this.addSpace,
    required this.removeLine,
    required this.moveLine,
  });

  // Class attributes
  final Color addLine;
  final Color addSpace;
  final Color removeLine;
  final Color moveLine;

  @override
  ThemeExtension<CustomButtonTheme> copyWith({
    Color? addLine,
    Color? addSpace,
    Color? removeLine,
    Color? moveLine
  }) {
    // Return a new instance of the class with the new values
    return CustomButtonTheme(
      addLine: addLine ?? this.addLine,
      addSpace: addSpace ?? this.addSpace,
      removeLine: removeLine ?? this.removeLine,
      moveLine: moveLine ?? this.moveLine
    );
  }

  @override
  ThemeExtension<CustomButtonTheme> lerp(CustomButtonTheme? other, double t) {
    // If the other object is not of the same type, return the current object
    if (other is! CustomButtonTheme) return this;

    // Return a new instance of the class with the interpolated values
    return CustomButtonTheme(
      addLine: Color.lerp(addLine, other.addLine, t)!,
      addSpace: Color.lerp(addSpace, other.addSpace, t)!,
      removeLine: Color.lerp(removeLine, other.removeLine, t)!,
      moveLine: Color.lerp(moveLine, other.moveLine, t)!
    );
  }
}

class SnackBarTheme extends ThemeExtension<SnackBarTheme> {
  /// Extends [ThemeData] to include custom snackbar colors
  /// 
  /// The custom colors defined are:
  /// - [success] is the color of the success snackbar
  /// - [warning] is the color of the warning snackbar
  /// - [error] is the color of the error snackbar
  /// - [info] is the color of the info snackbar
  const SnackBarTheme({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  // Class attributes
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  @override
  ThemeExtension<SnackBarTheme> copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    // Return a new instance of the class with the new values
    return SnackBarTheme(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<SnackBarTheme> lerp(SnackBarTheme? other, double t) {
    // If the other object is not of the same type, return the current object
    if (other is! SnackBarTheme) return this;

    // Return a new instance of the class with the interpolated values
    return SnackBarTheme(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
