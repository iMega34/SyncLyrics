
import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncedLyricsState {
  /// State for the synchronized lyrics provider
  ///
  /// Parameters:
  /// - [track] is the name of the track
  /// - [artist] is the artist of the track
  /// - [rawSyncedLyrics] are the synchronized lyrics of the track as a [String]
  /// - [parsedLyrics] are the parsed synchronized lyrics of the track as a [List]
  ///   of [Map]s with its timestamp and lyrics as [String]s
  const SyncedLyricsState({this.track, this.artist, this.rawSyncedLyrics, this.parsedLyrics});

  // Class attributes
  final String? track;
  final String? artist;
  final String? rawSyncedLyrics;
  final List<Map<String, String>>? parsedLyrics;

  /// Copy the current state with new values
  ///
  /// Parameters:
  /// - [track] is the name of the track as a [String]
  /// - [artist] is the artist of the track as a [String]
  /// - [rawSyncedLyrics] is the synchronized lyrics for the track as a [String]
  /// - [parsedLyrics] is the parsed synchronized lyrics for the track as a [List]
  ///  of [Map]s with its timestamp and lyrics as [String]s
  SyncedLyricsState copyWith({
    String? track,
    String? artist,
    String? rawSyncedLyrics,
    List<Map<String, String>>? parsedLyrics
  }) => SyncedLyricsState(
    track: track ?? this.track,
    artist: artist ?? this.artist,
    rawSyncedLyrics: rawSyncedLyrics ?? this.rawSyncedLyrics,
    parsedLyrics: parsedLyrics ?? this.parsedLyrics
  );
}

class SyncedLyricsNotifier extends StateNotifier<SyncedLyricsState> {
  /// Synchronized lyrics provider
  ///
  /// Stores the synchronized lyrics for a track and implements methods to support
  /// editing and downloading the synchronized lyrics as LRC files
  ///
  /// The initial state is an empty state, with no synchronized lyrics
  SyncedLyricsNotifier() : super(const SyncedLyricsState());

  /// Get the track information from the state
  /// 
  /// Returns:
  /// - A named [Record] with the following fields:
  ///   - `track`: A [String] with the name of the track
  ///   - `artist`: A [String] with the artist of the track
  ///   - `parsedLyrics`: A [List] of [Map]s with the timestamp and associated lyrics as [String]s
  ({String? track, String? artist, List<Map<String, String>>? parsedLyrics}) get trackInfo
    => (track: state.track, artist: state.artist, parsedLyrics: state.parsedLyrics);

  /// Loads the synchronized lyrics for a given track into the state by parsing the
  /// provided lyrics as a [String]
  ///
  /// The synchronized lyrics are stored in the state as a [List] of [Map]s, where
  /// the key the timestamp and the value the associated lyrics, both as [String]s.
  ///
  /// Parameters:
  /// - [track] is the name of the track
  /// - [artist] is the artist of the track
  /// - [lyrics] is the synchronized lyrics of the track as a [String]
  ///
  /// Detailed example:
  ///
  /// Splits the lyrics by line. Note:
  /// - The last two lines are removed to avoid parsing errors.
  /// - The timestamp is stored without the square brackets for easier display and editing.
  ///
  /// The Musixmatch API returns the synchronized lyrics as shown below:
  ///
  /// ```txt
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me
  /// (...)
  /// [03:54.12] Tell me you love me (love me)
  /// [03:56.49] Say I'm the only one (ooh-ooh)
  /// [04:03.16]     <- Final space. Not needed to be parsed.
  ///                <- Empty line. By not removing it, the mapping to the [List] of
  ///                   [Map]s will fail, throwing a `RangeError` (RangeError (end):
  ///                   Invalid value: Only valid value is 0: 10)
  /// ```
  /// 
  /// The synchronized lyrics are then mapped to a [List] of [Map]s with the timestamp
  /// and associated lyrics as [String]s.
  /// 
  /// ```dart
  /// final lyrics = """
  /// [00:33.37] Come on and lay with me
  /// [00:35.52] Come on and lie to me
  /// (...)
  /// [03:54.12] Tell me you love me (love me)
  /// [03:56.49] Say I'm the only one (ooh-ooh)
  /// """;
  /// 
  /// loadSyncedLyrics("Lie to Me", "Depeche Mode", lyrics);
  /// print(state.parsedLyrics); // [
  /// //  {"00:33.37": "Come on and lay with me"},
  /// //  {"00:35.52": "Come on and lie to me"},
  /// //  (...)
  /// //  {"03:54.12": "Tell me you love me (love me)"},
  /// //  {"03:56.49": "Say I'm the only one (ooh-ooh)"}
  /// // ]
  /// ```
  ///
  /// Track used for testing: "Lie to Me" by Depeche Mode
  /// Used Musixmatch track ID: 283511245
  void loadSyncedLyrics(String track, String artist, String lyrics) {
    // Remove the last two lines to avoid parsing errors
    final lines = List<String>.from(lyrics.split("\n"))
      ..removeLast()..removeLast();
    // Maps the lines to a list of maps, removing the square brackets from the timestamp
    // and storing the timestamp and lyrics as strings
    final parsedLyrics = List<Map<String, String>>.from(
      lines.map((String line) => {line.substring(1, 9) : line.substring(11)})
    );

    // Store the synchronized lyrics as both a [String] and a [List] of [Map]s, including
    // the track and artist in the state
    state = state.copyWith(track: track, artist: artist, rawSyncedLyrics: lyrics, parsedLyrics: parsedLyrics);
  }

  // TODO: Implement custom default download directory in the app settings
  /// Download the synchronized lyrics as a file
  ///
  /// The file is saved by default in the `Downloads` directory of the device,
  /// however, the user can select the directory where the file will be saved.
  /// 
  /// Parameters:
  /// - [asTxtFile] is a flag to save the LRC file as a `.txt` file instead of a `.lrc` file
  ///
  /// The file is named as `artist - track.lrc`.
  void downloadFile({bool asTxtFile = false}) async {
    final initDirectory = (await getDownloadsDirectory())!.path;
    // Get the directory where the user wants to save the LRC file, showing a dialog
    // opened in the default directory
    final downloadDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select the directory to save synchronized lyrics",
      initialDirectory: initDirectory,
      lockParentWindow: true
    );

    // Assign the extension of the file based on the 'asTxtFile' flag
    final extension = asTxtFile ? "txt" : "lrc";

    // Create, write and save the LRC file in the selected directory
    final file = File("$downloadDirectory/${state.artist} - ${state.track}.$extension");
    await file.writeAsString(state.rawSyncedLyrics!);
  }
}

/// Synchronized lyrics provider
///
/// Stores the synchronized lyrics for a track and implements methods to support
/// editing and downloading the synchronized lyrics as LRC files
///
/// The initial state is an empty state, with no synchronized lyrics
final syncedLyricsProvider = StateNotifierProvider<SyncedLyricsNotifier, SyncedLyricsState>(
  (ref) => SyncedLyricsNotifier(),
);

/// Musixmatch synced lyrics stream provider
///
/// Musixmatch client to fetch synchronized lyrics for a track given its Musixmatch ID
///
/// Parameters:
/// - [trackID] is the Musixmatch ID for the track
///
/// Returns:
/// - A stream of synchronized lyrics for the track
final musixmatchSyncedLyricsStreamProvider = StreamProvider.autoDispose.family<String, String>((ref, trackID) async* {
  // Execute the Python script to fetch the synchronized lyrics
  final script = await run("python lib/utils/musixmatch.py $trackID");
  final output = script[0];

  // Check if the Python script was executed successfully
  if (output.exitCode != 0) throw ("Error executing Python script: ${output.stderr}");

  // Yield the synchronized lyrics from the Python script
  final syncedLyrcis = output.stdout;
  yield syncedLyrcis;
});
