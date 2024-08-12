
import 'package:flutter/material.dart';

/// Extensions for Dart's built-in [bool] class.
extension BoolToInt on bool {
  /// Converts a boolean value into its integer representation.
  int toInt() => this ? 1 : 0;
}

/// Extensions for Dart's built-in [String] class.
extension StringExtension on String {
  /// Returns a capitalized version of the string. Returns an empty string if the
  /// string is empty.
  String toCapitalized() => isNotEmpty
    ? "${this[0].toUpperCase()}${substring(1).toLowerCase()}".trim()
    : "";

  /// Returns a title-cased version of the string. Returns an empty string if the
  /// string is empty.
  String toTitleCase() => isNotEmpty
    ? trim()
      .split(RegExp(' +'))
      .map((String str) => str.toCapitalized())
      .join(' ')
    : "";
}

/// Extensions for Dart's built-in [MapEntry] class.
extension MapEntryToRecord<K, V> on MapEntry<K, V> {
  /// Converts a [MapEntry] into a record for easy value retrieval.
  (K key, V value) get record => (key, value);
}

/// Extensions for Dart's built-in [String] class.
extension TextWidth on String {
  /// Get the width and height of a text when rendered on the screen as a
  /// named [Record] with keys `width` and `height`.
  ({double width, double height}) get textSize {
    // Return 0 if the text is empty
    if (isEmpty) return (width: 0, height: 0);

    // Create a text painter to measure the text width
    final textPainter = TextPainter(
      text: TextSpan(text: this),
      textDirection: TextDirection.ltr,
      maxLines: 1
    )..layout(maxWidth: double.infinity);

    return (width: textPainter.width, height: textPainter.height);
  }

  /// Get the width of a text when rendered on the screen as a [double].
  double get textWidth {
    // Return 0 if the text is empty
    if (isEmpty) return 0;

    // Create a text painter to measure the text width
    final textPainter = TextPainter(
      text: TextSpan(text: this),
      textDirection: TextDirection.ltr,
      maxLines: 1
    )..layout(maxWidth: double.infinity);

    return textPainter.width;
  }

  /// Get the height of a text when rendered on the screen as a [double].
  double get textHeight {
    // Return 0 if the text is empty
    if (isEmpty) return 0;

    // Create a text painter to measure the text height
    final textPainter = TextPainter(
      text: TextSpan(text: this),
      textDirection: TextDirection.ltr,
      maxLines: 1
    )..layout(maxWidth: double.infinity);

    return textPainter.height;
  }
}
