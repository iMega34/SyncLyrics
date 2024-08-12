
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_snack_bar.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';
import 'package:sync_lyrics/providers/musixmatch_synced_lyrics_provider.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';

/// Defines the result of an action in the toolbar
/// 
/// - [cantDownload] indicates that the lyrics can't be downloaded due to duplicates found
///   or the lyrics are unordered; this is shown as an error
/// - [issuesFound] indicates that either duplicates, unordered lyrics, or both were found; this
///   is shown as a warning message
/// - [success] indicates that the action was successful; this is shown as a success message
enum ToolbarActionResult { cantDownload, issuesFound, success }

class Toolbar extends ConsumerStatefulWidget {
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
        action: () {},
        tooltip: "Capitalize the first letter of each line"
      ),
    ];
  }

  /// Handles the status code of an action
  /// 
  /// Parameters:
  /// - [result] is the result of the action
  /// - [title] is an optional title for the snackbar
  /// - [message] is an optional message for the snackbar
  void _handleStatusCode(ToolbarActionResult result, {String title = "Success", String message = "Success"}) {
    switch (result) {
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
      case ToolbarActionResult.success:
        showCustomSnackBar(
          context,
          type: SnackBarType.success,
          title: title,
          message: message,
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
    _handleStatusCode(ToolbarActionResult.success, title: "Downloaded", message: "Lyrics downloaded successfully");
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
    _handleStatusCode(ToolbarActionResult.success, title: "No issues", message: "No duplicates or unordered lyrics found");
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
          ),
        )).toList(),
      )
    );
  }
}
