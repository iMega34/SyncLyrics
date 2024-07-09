
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  /// - [multilineMode] is whether the multiline mode is enabled
  const WorkspaceState({
    this.track,
    this.artist,
    this.parsedLyrics,
    this.selectedLine,
    this.selectedLines,
    this.multilineMode
  });

  // Class attributes
  final String? track;
  final String? artist;
  final List<Map<String, String>>? parsedLyrics;
  final int? selectedLine;
  final List<int>? selectedLines;
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
  /// - [multilineMode] is whether the multiline mode is enabled as a [bool]
  WorkspaceState copyWith({
    String? track,
    String? artist,
    List<Map<String, String>>? parsedLyrics,
    int? selectedLine,
    List<int>? selectedLines,
    bool? multilineMode
  }) => WorkspaceState(
    track: track ?? this.track,
    artist: artist ?? this.artist,
    parsedLyrics: parsedLyrics ?? this.parsedLyrics,
    selectedLine: selectedLine ?? this.selectedLine,
    selectedLines: selectedLines ?? this.selectedLines,
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
    multilineMode: multilineMode
  );
}

class WorkspaceNotifier extends StateNotifier<WorkspaceState> {
  WorkspaceNotifier() : super(const WorkspaceState());

  /// Load the lyrics into the workspace
  ///
  /// Parameters:
  /// - [parsedLyrics] are the parsed synchronized lyrics of the track as a [List]
  ///  of [Map]s with its timestamp and lyrics as [String]s
  void loadLyrics(List<Map<String, String>> parsedLyrics)
    => state = state.copyWith(parsedLyrics: parsedLyrics);

  /// Select a line in the workspace
  ///
  /// Parameters:
  /// - [index] is the index of the selected line
  void selectLine(int index) => state = state.copyWith(selectedLine: index);

  /// Clears the state to deselect the line in the workspace
  void deselectLine() => state = state.clearLine();

  /// Parse a timestamp from a string
  ///
  /// The timestamp should be in the '[mm:ss.xx]' or '[mm:ss:xx]' format, For example:
  /// 
  /// ```dart
  /// final timestamp = _parseTimestamp("03:54.12");
  /// print(timestamp.runtimeType); // Output: Duration
  /// print(timestamp); // Output: 0:03:54.120000
  /// ```
  ///
  /// Parameters:
  /// - [timestamp] is the timestamp as a [String]
  /// - [adjustMilliseconds] is whether to adjust milliseconds from the range of [0, 99]
  ///   to [0, 999]. Default value is `true`
  ///
  /// Returns:
  /// - The parsed timestamp as a [Duration] object
  Duration _parseTimestamp(String timestamp, {bool adjustMilliseconds = true}) {
    // Split the timestamp into minutes, seconds, and milliseconds and convert them
    // to a [Duration] object
    //
    // The Musixmatch API returns timestamps in the format of '[mm:ss.xx]' as shown below:
    //
    // [00:33.37] Come on and lay with me
    // [00:35.52] Come on and lie to me
    // (...)
    // [03:54.12] Tell me you love me (love me)
    // [03:56.49] Say I'm the only one (ooh-ooh)
    //
    // However, to ensure compatibility with other sources such as the user's own LRC files,
    // the function also accepts timestamps in the format of '[mm:ss:xx]'.
    //
    // Track used for testing: "Lie to Me" by Depeche Mode
    // Used Musixmatch track ID: 283511245

    // Check if the timestamp is in the correct format
    final regex = RegExp(r"\[\d{2}:\d{2}[:.]\d{2}\]");
    if (!regex.hasMatch(timestamp)) {
      throw const FormatException("Timestamp should be either in the format of `[mm:ss.xx]` or `[mm:ss:xx]`");
    }

    // Split the timestamp into minutes, seconds, and milliseconds and convert them
    // to a [Duration] object.
    //
    // Note that the milliseconds can be multiplied by 10 to convert them to the correct range,
    // since the [Duration] class expects the milliseconds to be in the range of [0, 999]
    // while the Musixmatch API returns them in the range of [0, 99].
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
  /// - The duration as a [String]
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

    final millisecondsText = totalMilliseconds.toString().padLeft(2, "0");

    return "$minutesPadding$minutes:$secondsPadding$seconds.$millisecondsText";
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
  /// Throws:
  /// - [StateError] if either the parsed lyrics or selected line are `null`
  /// 
  /// Detailed example:
  /// 
  /// The function will add a new line as shown below:
  /// 
  /// ```txt
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Selected line, the new line will be added below this one
  /// [00:37.49] Tell me you love me     <- Adjacent line
  /// [00:39.12] Say I'm the only one
  ///
  /// Since the new line will be added below the selected line, its timestamp will be the average
  /// between [00:35.52] and [00:37.49], which is [00:36.50], hence the new line will be added
  /// as shown below:
  ///
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Selected line
  /// [00:36.50] New line                <- Added line
  /// [00:37.49] Tell me you love me     <- Original adjacent line
  /// [00:39.12] Say I'm the only one
  ///
  /// If it happens that `addSpacer` is set to `true`, then the new line will only contain its
  /// corresponding timestamp without any lyrics, as shown below:
  ///
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me   <- Selected line
  /// [00:36.50]                         <- Added spacer line
  /// [00:37.49] Tell me you love me     <- Original adjacent line
  /// [00:39.12] Say I'm the only one
  /// ```
  ///
  /// Track used for testing: "Lie to Me" by Depeche Mode
  /// Used Musixmatch track ID: 283511245
  void addLine({bool addBelow = false, bool addSpacer = false}) {
    // Check if the parsed lyrics or selected line is null
    if (state.parsedLyrics == null || state.selectedLine == null) {
      throw StateError("Either parsed lyrics or selected line are `null`");
    }

    final parsedLyrics = state.parsedLyrics!;
    final index = state.selectedLine!;
    final newLineIndex = addBelow ? index + 1 : index - 1;

    // Get the timestamps of the selected line and the adjacent line
    final selectedLine = parsedLyrics[index].keys.first;
    final adjacentLine = parsedLyrics[newLineIndex].keys.first;

    // Parse the timestamps into a [Duration] object
    final selectedLineTimestamp = _parseTimestamp(selectedLine);
    final adjacentLineTimestamp = _parseTimestamp(adjacentLine);

    // Calculate the average of the timestamps to get the new line's timestamp
    final newLineTimestamp = _timestampAsString((selectedLineTimestamp + adjacentLineTimestamp) ~/ 2);

    // Insert the new line into the parsed lyrics and update the state
    parsedLyrics.insert(newLineIndex, {"[$newLineTimestamp]" : addSpacer ? "" : "New line"});
    state = state.copyWith(parsedLyrics: parsedLyrics);
  }
}

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, WorkspaceState>(
  (ref) => WorkspaceNotifier()
);
