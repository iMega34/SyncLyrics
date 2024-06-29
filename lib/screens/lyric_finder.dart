
import 'package:flutter/material.dart';

import 'package:sync_lyrics/widgets/lyrics_finder/results_list.dart';
import 'package:sync_lyrics/widgets/lyrics_finder/search_fields.dart';

class LyricsGeneratorScreen extends StatelessWidget {
  const LyricsGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: const Column(
        children: [
          SearchFields(),
          ResultsList()
        ],
      ),
    );
  }
}
