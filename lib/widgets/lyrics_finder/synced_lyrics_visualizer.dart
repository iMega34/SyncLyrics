
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/routes/router.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';
import 'package:sync_lyrics/providers/musixmatch_synced_lyrics_provider.dart';

class SyncedLyricsVisualizer extends ConsumerStatefulWidget {
  /// Display the synchronized lyrics of a track
  /// 
  /// Parameters:
  /// - [artist] is the artist of the track
  /// - [track] is the title of the track
  /// - [trackID] is the Musixmatch ID of the track
  const SyncedLyricsVisualizer({super.key, required this.artist, required this.track, required this.trackID});

  // Class attributes
  final String artist;
  final String track;
  final String trackID;

  @override
  ConsumerState<SyncedLyricsVisualizer> createState() => _SyncedLyricsVisualizerState();
}

class _SyncedLyricsVisualizerState extends ConsumerState<SyncedLyricsVisualizer> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final syncedLyricsStream = ref.watch(musixmatchSyncedLyricsStreamProvider(widget.trackID));
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(25),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Text(widget.track, style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
              Text(widget.artist, style: textTheme.bodyLarge),
              const SizedBox(height: 10),
              Expanded(
                child: syncedLyricsStream.when(
                  data: (String syncedLyrics) => SingleChildScrollView(
                    child: SelectableText(syncedLyrics, style: textTheme.bodyMedium),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      "Error while fetching synchronized lyrics",
                      style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)
                    ),
                  ),
                  loading: () => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        Text("Fetching synchronized lyrics...", style: textTheme.titleMedium!)
                      ],
                    )
                  )
                )
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeumorphicButton(
                    label: "Close",
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    onPressed: () => Navigator.pop(context)
                  ),
                  NeumorphicButton(
                    label: "Edit lyrics",
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    onPressed: () {
                      Navigator.pop(context);
                      AppRouter.changeScreen(context, 1);
                    }
                  ),
                  NeumorphicButton(
                    label: "Download LRC file",
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    onPressed: () => print("LRC file downloaded")
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }
}
