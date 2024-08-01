
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/extensions.dart';

class WorkspaceState {
  /// State for the workspace provider
  ///
  /// Parameters:
  /// - [track] is the name of the track
  /// - [artist] is the artist of the track
  /// - [parsedLyrics] are the parsed synchronized lyrics of the track as a [List]
  ///    of [Map]s with its timestamp and lyrics as [String]s
  /// - [selectedLine] is the index of the selected line
  /// - [selectedLines] are the indices of the selected lines
  /// - [duplicateLines] are the indices of the duplicate lines
  /// - [unorderedLines] are the indices of the unordered lines
  /// - [multilineMode] is whether the multiline mode is enabled
  const WorkspaceState({
    this.track,
    this.artist,
    this.parsedLyrics,
    this.selectedLine,
    this.selectedLines,
    this.duplicateLines,
    this.unorderedLines,
    this.multilineMode
  });

  // Class attributes
  final String? track;
  final String? artist;
  final List<Map<String, String>>? parsedLyrics;
  final int? selectedLine;
  final List<int>? selectedLines;
  final List<int>? duplicateLines;
  final List<int>? unorderedLines;
  final bool? multilineMode;

  /// Copy the current state with new values
  ///
  /// Parameters:
  /// - [track] is the name of the track as a [String]
  /// - [artist] is the artist of the track as a [String]
  /// - [parsedLyrics] are the parsed synchronized lyrics of the track as a [List]
  ///   of [Map]s with its timestamp and lyrics as [String]s
  /// - [selectedLine] is the index of the selected line as an [int]
  /// - [selectedLines] are the indices of the selected lines as a [List] of [int]s
  /// - [duplicateLines] are the indices of the duplicate lines as a [List] of [int]s
  /// - [unorderedLines] are the indices of the unordered lines as a [List] of [int]s
  /// - [multilineMode] is whether the multiline mode is enabled as a [bool]
  WorkspaceState copyWith({
    String? track,
    String? artist,
    List<Map<String, String>>? parsedLyrics,
    int? selectedLine,
    List<int>? selectedLines,
    List<int>? duplicateLines,
    List<int>? unorderedLines,
    bool? multilineMode
  }) => WorkspaceState(
    track: track ?? this.track,
    artist: artist ?? this.artist,
    parsedLyrics: parsedLyrics ?? this.parsedLyrics,
    selectedLine: selectedLine ?? this.selectedLine,
    selectedLines: selectedLines ?? this.selectedLines,
    duplicateLines: duplicateLines ?? this.duplicateLines,
    unorderedLines: unorderedLines ?? this.unorderedLines,
    multilineMode: multilineMode ?? this.multilineMode
  );

  /// Clear the selected line
  ///
  /// Useful for deselecting a line
  ///
  /// Returns:
  /// - A new [WorkspaceState] with [selectedLine] set to `null`
  WorkspaceState clearLine() => WorkspaceState(
    track: track,
    artist: artist,
    parsedLyrics: parsedLyrics,
    selectedLine: null,
    selectedLines: selectedLines,
    duplicateLines: duplicateLines,
    unorderedLines: unorderedLines,
    multilineMode: multilineMode
  );
}

class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  WorkspaceNotifier() : super(const WorkspaceState());

  /// Updates the lyrics in the workspace.
  ///
  /// This function can be used to load the lyrics for the first time or update them
  /// whenever a change happens.
  ///
  /// Parameters:
  /// - [track] is the name of the track as a [String]
  /// - [artist] is the artist of the track as a [String]
  /// - [parsedLyrics] are the parsed synced lyrics of the track as a [List]
  ///   of [Map]s with its timestamp and lyrics as [String]s.
  void initializeSyncedLyrics(String track, String artist, List<Map<String, String>> parsedLyrics)
    => state = state.copyWith(track: track, artist: artist, parsedLyrics: parsedLyrics);

  /// Sets the track name displayed in the workspace
  /// 
  /// Parameters:
  /// - [track] is the track name to be displayed
  void setTrack(String track) => state = state.copyWith(track: track);

  /// Sets the artist name displayed in the workspace
  /// 
  /// Parameters:
  /// - [artist] is the artist name to be displayed
  void setArtist(String artist) => state = state.copyWith(artist: artist);

  /// Select a line in the workspace
  ///
  /// The selected line is used to perform operations such as moving, deleting, adding
  /// or editing
  ///
  /// Parameters:
  /// - [index] is the index of the selected line
  void selectLine(int index) => state = state.copyWith(selectedLine: index);

  /// Clears the state from the selected line
  void deselectLine() => state = state.clearLine();

  /// Save the content of a line in the workspace
  /// 
  /// Parameters:
  /// - [index] is the index of the line
  /// - [lineContent] is the content of the line as a [Map] with its timestamp and lyrics
  ///    as [String]s
  void saveLine(int index, Map<String, String> lineContent) {
    // Assign the new content to the line in the parsed lyrics
    final parsedLyrics = state.parsedLyrics!;
    parsedLyrics[index] = lineContent;

    state = state.copyWith(parsedLyrics: parsedLyrics);
  }

  /// Parse a timestamp from a string
  ///
  /// The timestamp should be in the '[mm:ss.xx]' format, since the Musixmatch API returns
  /// timestamps in this format. However, to ensure compatibility with other sources such as
  /// the user's own LRC files, the function also accepts timestamps in the format of
  /// '[mm:ss:xx]' as well. For example:
  ///
  /// ```dart
  /// final timestamp1 = _parseTimestamp("[03:54.12]");
  /// print(timestamp1.runtimeType); // Output: Duration
  /// print(timestamp1); // Output: 0:03:54.120000
  ///
  /// final timestamp2 = _parseTimestamp("[04:12:99"]);
  /// print(timestamp2.runtimeType); // Output: Duration
  /// print(timestamp2); // Output: 0:04:12.990000
  /// ```
  ///
  /// Parameters:
  /// - [timestamp] is the timestamp as a [String]
  /// - [adjustMilliseconds] defines if milliseconds should be adjusted from the [0, 99]
  ///     range to the [0, 999] range, since [Duration] class expects milliseconds to be
  ///     within that range. Default value is `true`
  ///
  /// Returns:
  /// - The parsed timestamp as a [Duration] object
  Duration _parseTimestamp(String timestamp, {bool adjustMilliseconds = true}) {
    // Check if the timestamp is in the correct format
    final regex = RegExp(r"\[\d{2}:\d{2}[:.]\d{2}\]");
    if (!regex.hasMatch(timestamp)) {
      throw const FormatException("Timestamp should be either in the format of `[mm:ss.xx]` or `[mm:ss:xx]`");
    }

    // Split the timestamp into minutes, seconds, and milliseconds and convert them
    // to a [Duration] object.
    final splittedTimestamp = timestamp.substring(1, 9).split(RegExp(r"[.:]"));
    final parsedTimestamp = Duration(
      minutes: int.parse(splittedTimestamp[0]),
      seconds: int.parse(splittedTimestamp[1]),
      milliseconds: adjustMilliseconds
        ? int.parse(splittedTimestamp[2]) * 10
        : int.parse(splittedTimestamp[2])
    );

    return parsedTimestamp;
  }

  /// Convert the duration to a [String] in the format of '[mm:ss.xx]' given a [Duration] object
  ///
  /// The returned [String] will represent milliseconds in the range of [0, 99] since
  /// both LRC files and the Musixmatch API handle milliseconds in this range. For example:
  ///
  /// ```dart
  /// final duration = Duration(minutes: 3, seconds: 54, milliseconds: 120);
  /// final timestamp = _timestampAsString(duration);
  /// print(timestamp); // Output: '03:54.12'
  /// ```
  ///
  /// Returns:
  /// - The duration as a [String] in the format of '[mm:ss.xx]'
  String _timestampAsString(Duration timestamp) {
    // Get the total milliseconds
    int totalMilliseconds = timestamp.inMilliseconds;

    final minutes = totalMilliseconds ~/ Duration.millisecondsPerMinute;
    totalMilliseconds = totalMilliseconds.remainder(Duration.millisecondsPerMinute);

    // Add a padding zero when the minutes are less than 10 to ensure the format is '[mm:ss.xx]'
    final minutesPadding = minutes < 10 ? "0" : "";

    final seconds = totalMilliseconds ~/ Duration.millisecondsPerSecond;
    totalMilliseconds = totalMilliseconds.remainder(Duration.millisecondsPerSecond);

    // Add a padding zero when the seconds are less than 10 to ensure the format is '[mm:ss.xx]'
    final secondsPadding = seconds < 10 ? "0" : "";

    // Milliseconds should be in the range of [0, 99] for compatibility with LRC files
    if (totalMilliseconds >= 100) {
      totalMilliseconds = totalMilliseconds ~/ 10;
    }

    // Ensure the milliseconds are padded with a zero when they are less than 10
    final millisecondsText = totalMilliseconds.toString().padLeft(2, "0");

    return "[$minutesPadding$minutes:$secondsPadding$seconds.$millisecondsText]";
  }

  /// Find duplicated lines in the parsed lyrics
  ///
  /// Duplicated lines in the parsed lyrics are considered to be lines with the same timestamp.
  /// Timestamps must be unique to ensure the synchronization of the lyrics is handled correctly
  /// on any platform or application.
  ///
  /// This function analyzes the parsed lyrics stored in `state.parsedLyrics`.
  ///
  /// Returns:
  /// - A named [Record] with the following fields:
  ///   - `statusCode`: An [int] representing the status code
  ///   - `duplicatesFound`: A [Map] of the line indices as [int] with their corresponding duplicate
  ///      timestamps as [String]
  ///
  /// Status codes:
  /// - `0` if duplicates were not found. All timestamps are unique
  /// - `1` if duplicates were found. One or more timestamps are duplicated
  /// - `-1` if the parsed lyrics are `null`. No lines loaded to check for duplicates
  ///
  /// Detailed example:
  ///
  /// ```dart
  /// final parsedLyrics = [
  ///   {"[00:33.37]" : "Come on and lay with me"},
  ///   {"[00:35.52]" : "Come on and lie to me"},
  ///   {"[00:35.52]" : "Come on and lie to me"},
  ///   {"[00:37.49]" : "Tell me you love me"},
  ///   {"[00:39.12]" : "Say I'm the only one"}
  /// ];
  /// final (:statusCode, :duplicatesFound) = findDuplicates();
  /// print(statusCode); Output: 1
  /// print(duplicatesFound); // Output: {
  /// //  1 : "[00:35.52] Come on and lie to me",
  /// //  2 : "[00:35.52] Come on and lie to me"
  /// // }
  /// ```
  ///
  /// Track used for testing: "Lie to Me" by Depeche Mode
  /// Used Musixmatch track ID: 283511245
  ({int statusCode, Map<int, String> duplicatesFound}) findDuplicates() {
    // Check if the parsed lyrics are null
    if (state.parsedLyrics == null) {
      return (statusCode: -1, duplicatesFound: {});
    }

    // Map for storing the occurrences of the timestamps
    final Map<String, List<int>> occurrences = {};
    for (final line in state.parsedLyrics!.indexed) {
      // Get the timestamp and content of the line, and add the index to the ocurrences map
      final timestamp = line.$2.entries.first.key;

      // Add the index to the list of the timestamp occurrences
      if (occurrences.containsKey(timestamp)) {
        occurrences[timestamp]!.add(line.$1);
        continue;
      }

      // Otherwise, create a new list with the index
      occurrences[timestamp] = [line.$1];
    }

    // Filter the occurrences to get only the duplicates
    final duplicatesFound = Map<int, String>.fromEntries(occurrences.entries
      .where((entry) => entry.value.length > 1)
      .expand((entry) => entry.value.map((idx) {
        final timestamp = entry.key;
        final content = state.parsedLyrics![idx][timestamp]!;
        return MapEntry(idx, "$timestamp $content");
      })
    ));

    return (statusCode: duplicatesFound.isNotEmpty.toInt(), duplicatesFound: duplicatesFound);
  }

  /// Check the chronological order of the parsed lyrics
  ///
  /// Unordered lines in the parsed lyrics are considered to be lines whose timestamps are not
  /// correctly placed in chronological ascending order. Chronological order is crucial for
  /// correct playback of the synchronized lyrics.
  ///
  /// This function analyzes the parsed lyrics stored in `state.parsedLyrics`.
  ///
  /// Returns:
  /// - A named [Record] with the following fields:
  ///   - `statusCode`: An [int] representing the status code
  ///   - `unorderedLines`: A [Map] of the line indices as [int] with their corresponding unordered
  ///      timestamps as [String]
  ///
  /// Status codes:
  /// - `0` if unordered lines were not found. All lines are in chronological order
  /// - `1` if unordered lines were found. One or more lines are not in chronological order
  /// - `-1` if the parsed lyrics are `null`. No lines loaded to check for chronological order
  ///
  /// Detailed example:
  ///
  /// ```dart
  /// final parsedLyrics = [
  ///   {"[00:33.37]" : "Come on and lay with me"},
  ///   {"[00:35.52]" : "Come on and lie to me"},
  ///   {"[00:37.49]" : "Tell me you love me"},
  ///   {"[00:36.50]" : "New line"},
  ///   {"[00:39.12]" : "Say I'm the only one"}
  /// ];
  /// final (:statusCode, :unorderedLines) = checkChronologicalOrder();
  /// print(statusCode); // Output: 1
  /// print(unorderedLines); // Output: {3 : "[00:36.50] New line"}
  /// ```
  ///
  /// Track used for testing: "Lie to Me" by Depeche Mode
  /// Used Musixmatch track ID: 283511245
  ({int statusCode, Map<int, String> unorderedLines}) checkChronologicalOrder() {
    // Check if the parsed lyrics are null
    if (state.parsedLyrics == null) {
      return (statusCode: -1, unorderedLines: {});
    }

    // Get the indices of the lines with their corresponding timestamps
    final timestampIndices = state.parsedLyrics!.indexed
      .map(((int, Map<String, String>) line) => {line.$1 : _parseTimestamp(line.$2.keys.first)})
      .toList();
    // Create a sorted list of the timestamps to compare with the original list
    final List<Map<int, Duration>> sortedTimestamps = List.from(timestampIndices)
      ..sort((a, b) => a.values.first.compareTo(b.values.first));

    // Store indices of the lines with their corresponding timestamps if an unordered line is found
    final Map<int, String> unorderedLines = {
      for (int idx = 0; idx < timestampIndices.length; idx++)
        if (timestampIndices[idx] != sortedTimestamps[idx])
          timestampIndices[idx].keys.first : _timestampAsString(timestampIndices[idx].values.first)
    };

    return (statusCode: unorderedLines.isNotEmpty.toInt(), unorderedLines: unorderedLines);
  }

  /// Validate the synchronized lyrics
  /// 
  /// This function validates the synchronized lyrics by checking for duplicates and ensuring
  /// the lines are in chronological order. If any duplicates or unordered lines are found, the
  /// indices of the lines will be stored in the state for the user to review and correct.
  /// 
  /// Returns:
  /// - `true` if the synchronized lyrics are valid
  bool validateSyncedLyrics() {
    final (statusCode: statusCode1, :duplicatesFound) = findDuplicates();
    final (statusCode: statusCode2, :unorderedLines) = checkChronologicalOrder();

    // Return true if no duplicates or unordered lines are found
    if (statusCode1 == 0 && statusCode2 == 0) return true;

    // Otherwise, update the state with the indices of the duplicate and unordered lines
    state = state.copyWith(
      duplicateLines: duplicatesFound.keys.toList(),
      unorderedLines: unorderedLines.keys.toList()
    );

    return false;
  }

  /// Add a new line either above or below the selected line
  ///
  /// The timestamp of the new line will be the average of the timestamps of the selected line and
  /// the adjacent line, where the format of the timestamp is '[mm:ss.xx]' to ensure coherence with
  /// LRC files format. The content of the new line will be 'New line'.
  ///
  /// Parameters:
  /// - [addBelow] defines if the new line should be added below the selected line.
  ///     Default value is `false`
  /// - [addSpacer] defines if the new line should be added as a spacer between two lines.
  ///     Default value is `false`
  ///
  /// Returns:
  /// - `0` if the new line was added successfully
  /// - `-1` if either the parsed lyrics or selected line are `null`
  ///
  /// Detailed example:
  ///
  /// The function will add a new line above the selected line as shown below:
  ///
  /// ```txt
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Adjacent line
  /// [00:37.49] Tell me you love me     <- Selected line, the new line will be added above
  /// [00:39.12] Say I'm the only one
  ///
  /// Since the new line will be added above the selected line, its timestamp will be the average
  /// between [00:37.49] and [00:35.52], which is [00:36.50], hence the new line will be added
  /// as shown below:
  ///
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Adjacent line
  /// [00:36.50] New line                <- Added line
  /// [00:37.49] Tell me you love me     <- Selected line
  /// [00:39.12] Say I'm the only one
  ///
  /// In the case like the one above, the selected line index will be updated to the original
  /// selected line index plus one, to ensure the selected line remains selected after the new
  /// line is added.
  ///
  /// If it happens that `addSpacer` is set to `true`, then the new line will only contain its
  /// corresponding timestamp without any lyrics, as shown below:
  ///
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Adjacent line
  /// [00:36.50]                         <- Added spacer line
  /// [00:37.49] Tell me you love me     <- Selected line
  /// [00:39.12] Say I'm the only one
  /// ```
  ///
  /// Track used for testing: "Lie to Me" by Depeche Mode
  /// Used Musixmatch track ID: 283511245
  int addLine({bool addBelow = false, bool addSpacer = false}) {
    // Check if the parsed lyrics or selected line is null
    if (state.parsedLyrics == null || state.selectedLine == null) {
      return -1;
    }

    final (parsedLyrics, index) = (state.parsedLyrics!, state.selectedLine!);
    final indexToAdd = addBelow ? index + 1 : index;

    // Get the timestamps of the selected line and the adjacent line. If the new line index
    // is equal to 0, the timestamp of the adjacent line will be set to '[00:00.00]', and if
    // it's greater than the length of the parsed lyrics, the timestamp of the adjacent line
    // will be set to '[99:59.99]'.
    final selectedLine = parsedLyrics[index].keys.first;
    final adjacentLine = indexToAdd == 0
      ? "[00:00.00]"
      : indexToAdd >= parsedLyrics.length
        ? "[99:59.99]"
        : parsedLyrics[indexToAdd].keys.first;

    // Parse the timestamps into a [Duration] object
    final selectedLineTimestamp = _parseTimestamp(selectedLine);
    final adjacentLineTimestamp = _parseTimestamp(adjacentLine);

    // Calculate the average of the timestamps to get the new line's timestamp
    final newLineTimestamp = _timestampAsString((selectedLineTimestamp + adjacentLineTimestamp) ~/ 2);

    // Insert the new line into the parsed lyrics and update the state, the selected line index
    // will be updated to the original selected line index plus one if the new line is added above
    // the selected line
    parsedLyrics.insert(indexToAdd, {newLineTimestamp : addSpacer ? "" : "New line"});
    state = state.copyWith(parsedLyrics: parsedLyrics, selectedLine: addBelow ? null : index + 1);
    return 0;
  }

  /// Move the selected line either up or down
  ///
  /// The content of the selected line will be swapped with the content of the adjacent line,
  /// leaving the timestamps unchanged.
  ///
  /// Parameters:
  /// - [moveDown] defines if the selected line should be moved down. Default value is `false`
  ///
  /// Returns:
  /// - `0` if the selected line was moved successfully
  /// - `-1` if either the parsed lyrics or selected line are `null`
  /// - `-2` if the operation can't be performed, e.g., trying to move the first line up
  ///
  /// Detailed example:
  ///
  /// The function will move the selected line down as shown below:
  ///
  /// ```txt
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Selected line, the line will be moved down
  /// [00:37.49] Tell me you love me     <- Adjacent line
  /// [00:39.12] Say I'm the only one
  ///
  /// Since the selected line will be moved down, its content will be swapped with the content
  /// of the adjacent line, resulting in the following:
  ///
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Tell me you love me     <- Original adjacent line
  /// [00:37.49] Come on and lie to me   <- Line moved down
  /// [00:39.12] Say I'm the only one
  /// ```
  ///
  /// This ensures the synchronization of the lyrics is maintained, as the chronological order
  /// of the timestamps is crucial for correct playback. Any changes to the timestamps must
  /// be done manually by the user.
  ///
  /// Track used for testing: "Lie to Me" by Depeche Mode
  /// Used Musixmatch track ID: 283511245
  int moveLine({bool moveDown = false}) {
    // Check if the parsed lyrics or selected line is null
    if (state.parsedLyrics == null || state.selectedLine == null) {
      return -1;
    }

    final (parsedLyrics, index) = (state.parsedLyrics!, state.selectedLine!);
    final adjacentLineIndex = moveDown ? index + 1 : index - 1;

    // Check if index of the line to be swapped is within the bounds of the parsed lyrics
    if (adjacentLineIndex < 0 || adjacentLineIndex >= parsedLyrics.length) {
      return -2;
    }

    // Get the timestamps and lyrics of both the selected line and the adjacent line
    final selectedLine = parsedLyrics[index].entries.first;
    final adjacentLine = parsedLyrics[adjacentLineIndex].entries.first;

    // Swap the lyrics of the selected line and the adjacent line, leaving the timestamps unchanged
    parsedLyrics[index] = {selectedLine.key : adjacentLine.value};
    parsedLyrics[adjacentLineIndex] = {adjacentLine.key : selectedLine.value};

    // Update the state with the new parsed lyrics and the index of the adjacent line
    state = state.copyWith(parsedLyrics: parsedLyrics, selectedLine: adjacentLineIndex);
    return 0;
  }

  /// Remove a line either above or below the selected line
  ///
  /// Both the timestamp and lyrics of the line to be removed will be deleted from the parsed lyrics.
  ///
  /// Parameters:
  /// - [removeBelow] defines if the line below the selected line should be removed. Default value is `false`
  /// - [thisLine] defines if the selected line should be removed. Default value is `false`
  ///
  /// Returns:
  /// - `0` if the line was removed successfully
  /// - `-1` if either the parsed lyrics or selected line are `null`
  /// - `-2` if the operation can't be performed, e.g., trying to remove below the last line
  ///
  /// Detailed example:
  ///
  /// The function will remove the line above the selected line as shown below:
  ///
  /// ```txt
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Adjacent line, the line will be removed
  /// [00:37.49] Tell me you love me     <- Selected line
  /// [00:39.12] Say I'm the only one
  ///
  /// Since the line above the selected line will be removed, the selected line will be moved up
  /// to replace the removed line, resulting in the following:
  ///
  /// [00:33.37] Come on and lay with me
  /// [00:37.49] Tell me you love me     <- This was the adjacent line, now it's the selected line
  /// [00:39.12] Say I'm the only one
  /// ```
  ///
  /// Track used for testing: "Lie to Me" by Depeche Mode
  /// Used Musixmatch track ID: 283511245
  int removeLine({bool removeBelow = false, bool thisLine = false}) {
    // Check if the parsed lyrics or selected line is null
    if (state.parsedLyrics == null || state.selectedLine == null) {
      return -1;
    }

    final (parsedLyrics, index) = (state.parsedLyrics!, state.selectedLine!);
    final indexToRemove = thisLine ? index : (removeBelow ? index + 1 : index - 1);

    // Check if the index to remove is within the bounds of the parsed lyrics
    if (indexToRemove < 0 || indexToRemove >= parsedLyrics.length) {
      return -2;
    }

    // Remove the line from the parsed lyrics and update the state, the selected line index
    // will be updated to the adjacent line index if the line above the selected line is removed
    parsedLyrics.removeAt(indexToRemove);
    state = state.copyWith(parsedLyrics: parsedLyrics, selectedLine: removeBelow ? null : indexToRemove);
    return 0;
  }
}

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, WorkspaceState>(
  (ref) => WorkspaceNotifier()
);
