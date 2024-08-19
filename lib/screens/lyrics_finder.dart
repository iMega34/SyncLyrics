
import 'package:flutter/material.dart';

import 'package:sync_lyrics/widgets/lyrics_finder/results_list.dart';
import 'package:sync_lyrics/widgets/lyrics_finder/search_fields.dart';

class LyricsFinderScreen extends StatelessWidget {
  /// Display the lyrics finder screen
  /// 
  /// The screen is composed of a search field and a list of results
  const LyricsFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          SearchFields(),
          ResultsList()
        ],
      ),
    );
  }
}
