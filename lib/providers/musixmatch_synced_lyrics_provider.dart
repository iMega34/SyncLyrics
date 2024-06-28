
import 'package:process_run/cmd_run.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusixmatchSyncedLyricsState {
  MusixmatchSyncedLyricsState({this.syncedLyrics});

  final String? syncedLyrics;

  MusixmatchSyncedLyricsState copyWith({String? syncedLyrics})
    => MusixmatchSyncedLyricsState(syncedLyrics: syncedLyrics ?? this.syncedLyrics);

  MusixmatchSyncedLyricsState clearLyrics() => MusixmatchSyncedLyricsState();
}

class MusixmatchSyncedLyricsNotifier extends StateNotifier<MusixmatchSyncedLyricsState>{
  MusixmatchSyncedLyricsNotifier() : super(MusixmatchSyncedLyricsState());

  Future<void> fetchSyncedLyrics(String trackID) async {
    final script = await run("python lib/utils/musixmatch.py $trackID");
    final output = script[0];

    if (output.exitCode != 0) throw ("Error executing Python script: ${output.stderr}");

    final syncedLyrcis = output.stdout;
    state = state.copyWith(syncedLyrics: syncedLyrcis);
  }
}

final musixmatchSyncedLyricsProvider = StateNotifierProvider<MusixmatchSyncedLyricsNotifier, MusixmatchSyncedLyricsState>(
  (ref) => MusixmatchSyncedLyricsNotifier()
);
