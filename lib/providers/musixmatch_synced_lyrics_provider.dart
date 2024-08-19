
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:sync_lyrics/providers/settings_provider.dart';

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
  SyncedLyricsNotifier(this.ref) : super(const SyncedLyricsState());

  final Ref ref;

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

  /// Download the synchronized lyrics as a file
  ///
  /// The file is saved to the directory specified in the `settingsProvider`, which can be
  /// changed by the user in the settings screen.
  /// 
  /// Parameters:
  /// - [asTxtFile] is a flag to save the LRC file as a `.txt` file instead of a `.lrc` file
  ///
  /// The file is named as `artist - track.lrc` or `artist - track.txt` based on the `asTxtFile` flag.
  void downloadFile({bool asTxtFile = false}) async {
    final downloadDirectory = ref.read(settingsProvider).downloadDirectory;

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
  (ref) => SyncedLyricsNotifier(ref),
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
  // Get the path to the Python script to fetch the synchronized lyrics
  final scriptPath = await _copyPythonScriptToLocalPath();

  // Execute the Python script to fetch the synchronized lyrics
  final process = await Process.run('python', [scriptPath, trackID]);

  // Log the error returned by the Python script to a file
  if (process.exitCode != 0) {
    final file = File("log.txt");
    file.writeAsStringSync("Error code: ${process.stderr}\n", mode: FileMode.append);
  }

  // Yield the synchronized lyrics from the Python script
  final syncedLyrics = process.stdout.toString();
  yield syncedLyrics;
});

/// Copy the Python script from the assets to a temporary directory
/// 
/// Required to execute the Python script to fetch the synchronized lyrics
/// 
/// Returns:
/// - The path to the Python script as a [String]
Future<String> _copyPythonScriptToLocalPath() async {
  // Get the temporary directory to store the Python script
  final tempDirectory = await getTemporaryDirectory();
  final path = "${tempDirectory.path}/musixmatch.py";

  // Copy the Python script to the temporary directory
  final byteData = await rootBundle.load('assets/resources/musixmatch.py');
  final file = File(path);
  await file.writeAsBytes(byteData.buffer.asUint8List());

  return path;
}
