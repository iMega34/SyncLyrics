
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
  /// - [rawLyrics] are the synchronized lyrics of the track as a [String]
  /// - [syncedLyrics] are the synchronized lyrics of the track as a [List]
  ///   of [Map]s with its timestamp and lyrics as [String]s
  const SyncedLyricsState({this.track, this.artist, this.rawLyrics, this.syncedLyrics});

  // Class attributes
  final String? track;
  final String? artist;
  final String? rawLyrics;
  final List<Map<String, String>>? syncedLyrics;

  /// Copy the current state with new values
  ///
  /// Parameters:
  /// - [track] is the name of the track as a [String]
  /// - [artist] is the artist of the track as a [String]
  /// - [rawLyrics] is the synchronized lyrics for the track as a [String]
  /// - [syncedLyrics] is the synchronized lyrics for the track as a [List]
  ///  of [Map]s with its timestamp and lyrics as [String]s
  SyncedLyricsState copyWith({
    String? track,
    String? artist,
    String? rawLyrics,
    List<Map<String, String>>? syncedLyrics
  }) => SyncedLyricsState(
    track: track ?? this.track,
    artist: artist ?? this.artist,
    rawLyrics: rawLyrics ?? this.rawLyrics,
    syncedLyrics: syncedLyrics ?? this.syncedLyrics
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

  /// Load to the state the synchronized lyrics for a given track by parsing the
  /// [String] containing them
  /// 
  /// The synchronized lyrics are stored in the state as a [List] of [Map]s, being
  /// the key the timestamp and the value the associated lyrics, both as [String]s
  ///
  /// Parameters:
  /// - [track] is the name of the track
  /// - [artist] is the artist of the track
  /// - [lyrics] is the synchronized lyrics for the track as a [String]
  void loadSyncedLyrics(String track, String artist, String lyrics) {
    // Splits the lyrics by line, and removes the last two lines to avoid parsing errors.
    //
    // The Musixmatch API returns the synchronized lyrics as shown below:
    //
    // [00:33.37] Come on and lay with me
    // [00:35.52] Come on and lie to me
    // (...)
    // [03:54.12] Tell me you love me (love me)
    // [03:56.49] Say I'm the only one (ooh-ooh)
    // [04:03.16]     <- Final space. Not needed to be parsed.
    //                <- Empty line. By not removing it, the mapping to the [List] of
    //                   [Map]s will fail, throwing a `RangeError` (RangeError (end):
    //                   Invalid value: Only valid value is 0: 10)
    //
    // Track used for testing: "Lie to Me" by Depeche Mode
    // Used Musixmatch track ID: 283511245
    final lines = List<String>.from(lyrics.split("\n"))
      ..removeLast()..removeLast();
    // Maps the lines to a list of maps with the timestamp and lyrics
    final syncedLyrics = List<Map<String, String>>.from(
      lines.map((String line) => {line.substring(0, 10) : line.substring(11)})
    );

    // Store the synchronized lyrics in the state
    state = state.copyWith(track: track, artist: artist, rawLyrics: lyrics, syncedLyrics: syncedLyrics);
  }

  // TODO: Implement custom default download directory in the app settings
  /// Download the synchronized lyrics as an LRC file
  /// 
  /// The LRC file is saved by default in the `Downloads` directory of the device,
  /// however, the user can select the directory where the file will be saved.
  /// 
  /// The file is named as `artist - track.lrc`.
  void downloadLRCFile() async {
    final initDirectory = (await getDownloadsDirectory())!.path;
    // Get the directory where the user wants to save the LRC file, showing a dialog
    // opened in the default directory
    final downloadDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select the directory to save synchronized lyrics",
      initialDirectory: initDirectory,
      lockParentWindow: true
    );

    // Create, write and save the LRC file in the selected directory
    final file = File("$downloadDirectory/${state.artist} - ${state.track}.lrc");
    await file.writeAsString(state.rawLyrics!);
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
