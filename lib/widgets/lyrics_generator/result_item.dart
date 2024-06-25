
import 'package:flutter/material.dart';
import 'package:sync_lyrics/utils/infinite_marquee_text.dart';

import 'package:sync_lyrics/utils/neumorphic.dart';
import 'package:sync_lyrics/providers/musixmatch_provider.dart';

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
          if (result["url"] == "No lyrics available")
            Center(child: InfiniteMarqueeText(text: "No lyrics available", style: Theme.of(context).textTheme.titleLarge)),
          SingleChildScrollView(
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
                  result["album"]!,
                  style: Theme.of(context).textTheme.labelMedium
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
