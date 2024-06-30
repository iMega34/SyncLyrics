
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/routes/dialog.dart';
import 'package:sync_lyrics/utils/infinite_marquee_text.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_fade.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';
import 'package:sync_lyrics/providers/musixmatch_results_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_finder/synced_lyrics_visualizer.dart';

class ResultItem extends ConsumerStatefulWidget {
  /// Display a single result from the Musixmatch provider
  /// 
  /// Parameters:
  /// - [result] is the result to be displayed
  const ResultItem({super.key, required this.result});

  // Class attributes
  final MusixmatchResult result;

  @override
  ConsumerState<ResultItem> createState() => _ResultItemState();
}

class _ResultItemState extends ConsumerState<ResultItem> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final track = widget.result["track"]!;
    final artist = widget.result["artist"]!;
    final album = widget.result["album"]!;
    final trackID = widget.result["track_id"]!;
    return NeumorphicButton(
      centerContent: false,
      enabled: trackID.isEmpty ? false : true,
      onPressed: () => openDialog(context, child: SyncedLyricsVisualizer(artist: artist, track: track, trackID: trackID)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track, style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
                  Text(artist, style: textTheme.bodyLarge),
                  Text(album, style: textTheme.labelMedium)
                ],
              ),
            ),
          ),
          // Display a message if the synchronized lyrics are not available
          if (trackID.isEmpty)
            Positioned(
              left: 0.0, right: 0.0, bottom: 0.0,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15)
                ),
                child: NeumorphicFade(
                  backgroundColor: Colors.red.shade400,
                  child: InfiniteMarqueeText(
                    text: "No lyrics available",
                    style: textTheme.titleMedium
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
