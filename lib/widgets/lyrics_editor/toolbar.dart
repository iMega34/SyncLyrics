
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_snack_bar.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';
import 'package:sync_lyrics/providers/musixmatch_synced_lyrics_provider.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';

/// Defines the result of an action in the toolbar
enum ToolbarActionResult {
  /// Indicates that the lyrics were downloaded successfully; shown as a success message
  fileDownloaded,
  /// Indicates that the lyrics can't be downloaded due to duplicates found or the lyrics are unordered;
  /// shown as an error
  cantDownload,
  /// Indicates that either duplicates, unordered lyrics, or both were found; shown as a warning message
  issuesFound,
  /// Indicates that no issues were found in the lyrics; shown as a success message
  noIssuesFound,
  /// Indicates that the lyrics were capitalized successfully; shown as a success message
  lyricsCapitalized,
  /// Indicates that the lyrics can't be capitalized due to duplicates found or the lyrics are unordered;
  /// shown as an error
  cantCapitalize
}

class Toolbar extends ConsumerStatefulWidget {
  /// A toolbar with buttons for performing actions on the workspace
  /// 
  /// The toolbar contains buttons for:
  /// - Downloading the lyrics as a `.txt`
  /// - Downloading the lyrics as a `.lrc`
  /// - Validating the lyrics
  /// - Capitalizing the lyrics
  const Toolbar({super.key});

  @override
  ConsumerState<Toolbar> createState() => _ToolbarState();
}

class _ToolbarButton {
  /// Defines the properties of a toolbar button
  /// 
  /// Parameters:
  /// - [label] is the text to display on the button
  /// - [action] is the function to execute when the button is pressed
  /// - [tooltip] is the text to display when hovering over the button
  const _ToolbarButton({
    required this.label,
    required this.action,
    required this.tooltip
  });

  // Class attributes
  final String label;
  final VoidCallback action;
  final String tooltip;
}

class _ToolbarState extends ConsumerState<Toolbar> {
  late List<_ToolbarButton> _buttons;

  @override
  void initState() {
    super.initState();
    _buttons = [
      _ToolbarButton(
        label: "Download .lrc",
        action: _downloadAction,
        tooltip: "Download the lyrics as a .lrc file"
      ),
      _ToolbarButton(
        label: "Download .txt",
        action: () => _downloadAction(asTxtFile: true),
        tooltip: "Download the lyrics as a .txt file"
      ),
      _ToolbarButton(
        label: "Validate",
        action: _validateAction,
        tooltip: "Validate lyrics don't have duplicates or are unordered"
      ),
      _ToolbarButton(
        label: "Capitalize",
        action: _capitalizeAction,
        tooltip: "Capitalize the first letter of each line"
      ),
    ];
  }

  /// Handles the status code of an action
  /// 
  /// Parameters:
  /// - [actionResult] is the result of the action
  void _handleStatusCode(ToolbarActionResult actionResult) {
    switch (actionResult) {
      case ToolbarActionResult.fileDownloaded:
        showCustomSnackBar(
          context,
          type: SnackBarType.success,
          title: "Downloaded",
          message: "File downloaded successfully",
        );
        break;
      case ToolbarActionResult.cantDownload:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Can't download",
          message: "Unordered lyrics or duplicates found, please verify the lyrics",
        );
        break;
      case ToolbarActionResult.issuesFound:
        showCustomSnackBar(
          context,
          type: SnackBarType.warning,
          title: "Issues found",
          message: "Unordered lyrics or duplicates found, please verify the lyrics",
        );
        break;
      case ToolbarActionResult.noIssuesFound:
        showCustomSnackBar(
          context,
          type: SnackBarType.success,
          title: "No issues",
          message: "No duplicates or unordered lyrics found",
        );
        break;
      case ToolbarActionResult.lyricsCapitalized:
        showCustomSnackBar(
          context,
          type: SnackBarType.success,
          title: "Capitalized",
          message: "Lyrics capitalized successfully",
        );
        break;
      case ToolbarActionResult.cantCapitalize:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Can't capitalize",
          message: "Unordered lyrics or duplicates found, please verify the lyrics",
        );
        break;
    }
  }

  /// Handles the download action
  /// 
  /// Downloads the lyrics as a `.lrc` file or a `.txt` file, to the download directory defined
  /// in the app settings.
  /// 
  /// Parameters:
  /// - [asTxtFile] is a flag to save the lyrics as a `.txt` file
  void _downloadAction({bool asTxtFile = false}) {
    // Apply the changes to the lyrics and validate them
    ref.read(workspaceProvider.notifier).applyChanges();
    final statusCode = ref.read(workspaceProvider.notifier).validateSyncedLyrics();

    // If issues are found, show a snackbar with the error message
    if (statusCode == -1) {
      _handleStatusCode(ToolbarActionResult.cantDownload);
      return;
    }

    // Load the synced lyrics to the 'syncedLyricsProvider' and download the file
    final (:track!, :artist!, :parsedLyrics!, :rawSyncedLyrics!) = ref.read(workspaceProvider.notifier).trackInfo;
    ref.read(syncedLyricsProvider.notifier).loadSyncedLyrics(track, artist, rawSyncedLyrics);
    ref.read(syncedLyricsProvider.notifier).downloadFile(asTxtFile: asTxtFile);
    _handleStatusCode(ToolbarActionResult.fileDownloaded);
  }

  /// Validates the lyrics
  /// 
  /// Verifies that the lyrics are in correct order and don't have any duplicates, and shows
  /// a snackbar based on the result.
  void _validateAction() {
    // Apply the changes to the lyrics and validate them
    ref.read(workspaceProvider.notifier).applyChanges();
    final statusCode = ref.read(workspaceProvider.notifier).validateSyncedLyrics();

    // If issues are found, show a snackbar with a warning message
    if (statusCode == -1) {
      _handleStatusCode(ToolbarActionResult.issuesFound);
      return;
    }

    // Otherwise, show a snackbar with a success message
    _handleStatusCode(ToolbarActionResult.noIssuesFound);
  }

  /// Capitalizes the lyrics
  /// 
  /// The first letter of each line is capitalized only if the lyrics pass the validation.
  void _capitalizeAction() {
    // Apply the changes to the lyrics and validate them
    ref.read(workspaceProvider.notifier).applyChanges();
    final statusCode = ref.read(workspaceProvider.notifier).validateSyncedLyrics();

    // If issues are found, show a snackbar with the error message
    if (statusCode == -1) {
      _handleStatusCode(ToolbarActionResult.cantCapitalize);
      return;
    }

    // Otherwise, capitalize the lyrics and show a success message
    ref.read(workspaceProvider.notifier).capitalizeLyrics();
    _handleStatusCode(ToolbarActionResult.lyricsCapitalized);
  }

  @override
  Widget build(BuildContext context) {
    final areLyricsAvailable = ref.watch(workspaceProvider).parsedLyrics != null;
    return Neumorphic(
      child: GridView(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 2 / 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2
        ),
        children: _buttons.map((_ToolbarButton button) => Tooltip(
          message: button.tooltip,
          child: NeumorphicButton(
            enabled: areLyricsAvailable,
            onPressed: button.action,
            label: button.label,
          )
        )).toList()
      )
    );
  }
}
