
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/neumorphic_fade.dart';
import 'package:sync_lyrics/utils/neumorphic_button.dart';
import 'package:sync_lyrics/utils/infinite_marquee_text.dart';
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
  /// Open the synchronized lyrics visualizer
  /// 
  /// Parameters:
  /// - [artist] is the artist of the track
  /// - [track] is the title of the track
  /// - [trackID] is the Musixmatch ID of the track
  void _openSyncedLyricsVisualizer(String artist, String track, String trackID) {
    final dialogScaleTween = Tween<double>(begin: 1.3, end: 1.0)
      .chain(CurveTween(curve: Curves.linearToEaseOut));
    showGeneralDialog(
      context: context,
      barrierLabel: "",
      barrierDismissible: true,
      // barrierDismissible: false,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => ScaffoldMessenger(
        child: Builder(
          builder: (context) => Scaffold(
            backgroundColor: Colors.transparent,
            body: SyncedLyricsVisualizer(artist: artist, track: track, trackID: trackID)
          )
        ),
      ),
      transitionBuilder: (_, animation, __, child) {
        final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        if (animation.status == AnimationStatus.reverse) {
          return FadeTransition(
            opacity: fadeAnimation,
            child: child
          );
        }
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: animation.drive(dialogScaleTween),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.result["track"] ?? "Unknown";
    final artist = widget.result["artist"] ?? "Unknown";
    final album = widget.result["album"] ?? "Unknown";
    final trackID = widget.result["track_id"] ?? "";
    return NeumorphicButton(
      centerContent: false,
      enabled: trackID.isEmpty ? false : true,
      onPressed: () => _openSyncedLyricsVisualizer(artist, track, trackID),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)
                  ),
                  Text(
                    artist,
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
                  Text(
                    album,
                    style: Theme.of(context).textTheme.labelMedium
                  )
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
                    style: Theme.of(context).textTheme.titleMedium,
                    speed: 25,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
