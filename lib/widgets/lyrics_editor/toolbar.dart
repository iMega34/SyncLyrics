
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_snack_bar.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';
import 'package:sync_lyrics/providers/musixmatch_synced_lyrics_provider.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';
import 'package:sync_lyrics/providers/settings_provider.dart';

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

class Toolbar extends ConsumerStatefulWidget {
  /// A toolbar with buttons for performing actions on the workspace
  /// 
  /// The toolbar contains buttons for:
  /// - Downloading the lyrics as a `.txt`
  /// - Downloading the lyrics as a `.lrc`
  /// - Validating the lyrics
  /// - Capitalizing the lyrics
  /// - Loading the lyrics from a file
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
  /// - [alwaysEnabled] is a flag to enable the button even if there are no lyrics available
  const _ToolbarButton({
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
      _ToolbarButton(
        label: "Load from file",
        action: _loadFromFileAction,
        tooltip: "Loads synced lyrics from a .lrc file\nThe content must be in the format: [mm:ss.xx] lyrics",
        alwaysEnabled: true
      )
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
      case ToolbarActionResult.cantDownloadInvalidLyrics:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Can't download",
          message: "Unordered lyrics or duplicates found, please verify the lyrics",
        );
        break;
      case ToolbarActionResult.cantDownloadInvalidInfo:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Can't download",
          message: "Track or artist name is empty, please fill in the information",
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
      case ToolbarActionResult.noSelectedFile:
        showCustomSnackBar(
          context,
          type: SnackBarType.warning,
          title: "No file selected",
          message: "Please select a file to load the lyrics from",
        );
        break;
      case ToolbarActionResult.syncedLyricsLoaded:
        showCustomSnackBar(
          context,
          type: SnackBarType.success,
          title: "Loaded",
          message: "Synced lyrics loaded successfully",
        );
        break;
      case ToolbarActionResult.cantLoadFromFile:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Can't load file",
          message: "The file content has an invalid format, please verify the file",
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
      _handleStatusCode(ToolbarActionResult.cantDownloadInvalidLyrics);
      return;
    }

    // Get the data from the workspace provider
    final (:track!, :artist!, :parsedLyrics!, :rawSyncedLyrics!) = ref.read(workspaceProvider.notifier).trackInfo;

    // If the track or artist name is empty, show a snackbar with an error message
    if (track.isEmpty || artist.isEmpty) {
      _handleStatusCode(ToolbarActionResult.cantDownloadInvalidInfo);
      return;
    }

    // Load the synced lyrics to the `syncedLyricsProvider` and download the file
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

  /// Loads the lyrics from a file
  /// 
  /// Either a `.lrc` or a `.txt` file can be selected to load the lyrics from.
  void _loadFromFileAction() async {
    // Get the initial directory to open the dialog, and show a dialog to select a directory
    final initDirectory = ref.read(settingsProvider).downloadDirectory;
    final selectedFile = await FilePicker.platform.pickFiles(
      dialogTitle: "Pick a file",
      initialDirectory: initDirectory,
      allowedExtensions: ['txt', 'lrc'],
      type: FileType.custom,
    );

    // If the user cancels the dialog, return
    if (selectedFile == null) {
      _handleStatusCode(ToolbarActionResult.noSelectedFile);
      return;
    }

    // Get the artist and track information from the filename
    final filename = selectedFile.names[0]!;
    final (:artist, :track) = _getTrackInfoFromFilename(filename);

    // Try loading the synced from the file
    final file = File(selectedFile.paths[0]!);
    final statusCode = await ref.read(workspaceProvider.notifier).loadFromFile(file, track, artist);

    // If the file content has an invalid format, show a snackbar with an error message
    if (statusCode == -1) {
      _handleStatusCode(ToolbarActionResult.cantLoadFromFile);
      return;
    }

    // Otherwise, show a snackbar with a success message
    _handleStatusCode(ToolbarActionResult.noIssuesFound);
  }

  /// Extracts the artist and track information from the filename
  /// 
  /// If the function fails to extract the information, it returns following default values:
  /// - Artist: "Artist"
  /// - Track: "Track"
  /// 
  /// Parameters:
  /// - [filename] is the name of the file
  /// 
  /// Returns:
  /// - A named [Record] with the following fields:
  ///   - [artist] is the name of the artist
  ///   - [track] is the name of the track
  ({String artist, String track}) _getTrackInfoFromFilename(String filename) {
    final filanameRegex = RegExp(r'^.+\s-\s.+$');
    final trackRegex = RegExp(r'\.(txt|lrc)$');

    // If the filename matches the pattern´"artist - track", split the filename and return the parts
    if (filanameRegex.hasMatch(filename)) {
      final parts = filename.split('-');
      final artist = parts[0].trim();
      final track = parts[1].trim().replaceAll(trackRegex, "");
      return (artist: artist, track: track);
    }

    // Otherwise, return the default values
    return (artist: "Artist", track: "Track");
  }

  @override
  Widget build(BuildContext context) {
    final areLyricsAvailable = ref.watch(workspaceProvider).parsedLyrics.isNotEmpty;
    return Expanded(
      child: Neumorphic(
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
              enabled: areLyricsAvailable || button.alwaysEnabled,
              onPressed: button.action,
              label: button.label,
            )
          )).toList()
        ),
      ),
    );
  }
}
