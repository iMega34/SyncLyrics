
import 'package:flutter/material.dart';

/// Defines the result of an action in the toolbar
enum ToolbarActionResult {
  /// Indicates that the lyrics were downloaded successfully; shown as a success message
  fileDownloaded,
  /// Indicates that the lyrics can't be downloaded due to duplicates found or the lyrics are unordered;
  /// shown as an error
  cantDownloadInvalidLyrics,
  /// Indicates that the lyrics can't be downloaded due to empty track name, artist name or both were found;
  /// shown as an error
  cantDownloadInvalidInfo,
  /// Indicates that either duplicates, unordered lyrics, or both were found; shown as a warning message
  issuesFound,
  /// Indicates that no issues were found in the lyrics; shown as a success message
  noIssuesFound,
  /// Indicates that the lyrics were capitalized successfully; shown as a success message
  lyricsCapitalized,
  /// Indicates that the lyrics can't be capitalized due to duplicates found or the lyrics are unordered;
  /// shown as an error
  cantCapitalize,
  /// Indicates that no file was selected; shown as a warning message
  noSelectedFile,
  // Indicates that the synced lyrics from the file were loaded successfully; shown as a success message
  syncedLyricsLoaded,
  /// Indicates that the file can't be loaded due to content having an invalid format; shown as an error
  cantLoadFromFile
}

class ToolbarButton {
  /// Defines the properties of a toolbar button
  /// 
  /// Parameters:
  /// - [label] is the text to display on the button
  /// - [action] is the function to execute when the button is pressed
  /// - [tooltip] is the text to display when hovering over the button
  /// - [alwaysEnabled] is a flag to enable the button even if there are no lyrics available
  const ToolbarButton({
    required this.label,
    required this.action,
    required this.tooltip,
    this.alwaysEnabled = false
  });

  // Class attributes
  final String label;
  final VoidCallback action;
  final String tooltip;
  final bool alwaysEnabled;
}
