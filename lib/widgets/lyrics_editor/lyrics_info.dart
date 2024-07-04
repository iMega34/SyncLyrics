
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/providers/musixmatch_synced_lyrics_provider.dart';

class LyricsInfo extends ConsumerWidget {
  /// Displays the track and artist of the synced lyrics, used in the `LyricsEditorScreen`
  /// 
  /// Listens to the `syncedLyricsProvider` to display the information related to the
  /// synced lyrics after fetching information form the track, either from the Musixmatch API
  /// or from a provided LRC file.
  /// 
  /// For more information regarding the `syncedLyricsProvider`, refer to the
  /// `musixmatch_synced_lyrics_provider.dart` file.
  const LyricsInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final lyricsInfo = ref.watch(syncedLyricsProvider);
    return Column(
      children: [
        // Display the track and artist of the synced lyrics, if available
        Text(lyricsInfo.track ?? "No track", style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
        Text(lyricsInfo.artist ?? "No artist", style: textTheme.bodyLarge),
      ],
    );
  }
}
