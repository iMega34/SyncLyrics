
import 'package:process_run/cmd_run.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncedLyricsState {
  /// State for the synchronized lyrics provider
  ///
  /// Parameters:
  /// - [syncedLyrics] is the synchronized lyrics for the track as a [List]
  ///   of [Map]s with its timestamp and lyrics as [String]s
  const SyncedLyricsState({this.syncedLyrics});

  // Class attributes
  final List<Map<String, String>>? syncedLyrics;

  /// Copy the current state with new values
  ///
  /// Parameters:
  /// - [syncedLyrics] is the synchronized lyrics for the track as a [List]
  ///  of [Map]s with its timestamp and lyrics as [String]s
  SyncedLyricsState copyWith({List<Map<String, String>>? syncedLyrics})
    => SyncedLyricsState(syncedLyrics: syncedLyrics ?? this.syncedLyrics);
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
  /// - [lyrics] is the synchronized lyrics for the track as a [String]
  void loadSyncedLyrics(String lyrics) {
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
    state = state.copyWith(syncedLyrics: syncedLyrics);
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
