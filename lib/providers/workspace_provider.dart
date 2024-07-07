
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

  /// Select a line in the workspace
  /// 
  /// Parameters:
  /// - [index] is the index of the selected line
  void selectLine(int index) => state = state.copyWith(selectedLine: index);

  /// Clears the state to deselect the line in the workspace
  void deselectLine() => state = state.clearLine();
}

final workspaceProvider = StateNotifierProvider<WorkspaceNotifier, WorkspaceState>(
  (ref) => WorkspaceNotifier()
);
