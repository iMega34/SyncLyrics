
import 'package:process_run/cmd_run.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusixmatchSyncedLyricsState {
  /// State for the Musixmatch synced lyrics provider
  /// 
  /// Parameters:
  /// - [syncedLyrics] is the synchronized lyrics for the current track
  MusixmatchSyncedLyricsState({this.syncedLyrics});

  // Class attributes
  final String? syncedLyrics;

  /// Copy the current state and update the synchronized lyrics
  /// 
  /// Parameters:
  /// - [syncedLyrics] is the new synchronized lyrics
  MusixmatchSyncedLyricsState copyWith({String? syncedLyrics})
    => MusixmatchSyncedLyricsState(syncedLyrics: syncedLyrics ?? this.syncedLyrics);
}

class MusixmatchSyncedLyricsNotifier extends StateNotifier<MusixmatchSyncedLyricsState>{
  /// Musixmatch synced lyrics provider
  /// 
  /// Musixmatch client to fetch synchronized lyrics for a track given its Musixmatch ID
  /// 
  /// The initial state is an empty state, with no synchronized lyrics
  MusixmatchSyncedLyricsNotifier() : super(MusixmatchSyncedLyricsState());

  /// Fetch synchronized lyrics for a track given its Musixmatch ID
  /// 
  /// Parameters:
  /// - [trackID] is the Musixmatch ID for the track
  Future<void> fetchSyncedLyrics(String trackID) async {
    // Execute the Python script to fetch the synchronized lyrics
    final script = await run("python lib/utils/musixmatch.py $trackID");
    final output = script[0];

    // Check if the Python script was executed successfully
    if (output.exitCode != 0) throw ("Error executing Python script: ${output.stderr}");

    // Update the state with the synchronized lyrics as the output of the Python script
    final syncedLyrcis = output.stdout;
    state = state.copyWith(syncedLyrics: syncedLyrcis);
  }
}

/// Musixmatch synced lyrics provider
/// 
/// Musixmatch client to fetch synchronized lyrics for a track given its Musixmatch ID
/// 
/// This initial state is an empty state, with no synchronized lyrics
final musixmatchSyncedLyricsProvider = StateNotifierProvider<MusixmatchSyncedLyricsNotifier, MusixmatchSyncedLyricsState>(
  (ref) => MusixmatchSyncedLyricsNotifier()
);
