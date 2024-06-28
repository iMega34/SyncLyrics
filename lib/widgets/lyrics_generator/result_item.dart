
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/neumorphic.dart';
import 'package:sync_lyrics/utils/neumorphic_fade.dart';
import 'package:sync_lyrics/utils/infinite_marquee_text.dart';
import 'package:sync_lyrics/providers/musixmatch_results_provider.dart';

class ResultItem extends StatelessWidget {
  /// Display a single result from the Musixmatch provider
  /// 
  /// Parameters:
  /// - [result] is the result to be displayed
  const ResultItem({super.key, required this.result});

  // Class attributes
  final MusixmatchResult result;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result["track"]!,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold
                    )
                  ),
                  Text(
                    result["artist"]!,
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
                  Text(
                    result["album"] ?? "Unknown",
                    style: Theme.of(context).textTheme.labelMedium
                  )
                ],
              ),
            ),
          ),
          // Display a message if the synchronized lyrics are not available
          if (result["track_id"]!.isEmpty)
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
