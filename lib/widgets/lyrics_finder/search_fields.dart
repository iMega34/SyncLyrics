
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/neumorphic_button.dart';
import 'package:sync_lyrics/utils/neumorphic_text_field.dart';
import 'package:sync_lyrics/providers/musixmatch_results_provider.dart';

class SearchFields extends ConsumerStatefulWidget {
  /// Search fields for the Musixmatch provider
  const SearchFields({super.key});

  @override
  ConsumerState<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends ConsumerState<SearchFields> {
  late TextEditingController _trackController = TextEditingController();
  late TextEditingController _artistController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trackController = TextEditingController();
    _artistController = TextEditingController();
  }

  @override
  void dispose() {
    _trackController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NeumorphicTextField(
            label: "Artist",
            controller: _artistController,
            margin: const EdgeInsets.only(right: 10),
          )
        ),
        Expanded(
          child: NeumorphicTextField(
            label: "Track",
            controller: _trackController,
            margin: const EdgeInsets.symmetric(horizontal: 10),
          )
        ),
        NeumorphicButton(
          label: "Search",
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          onPressed: () async {
            final qTrack = _trackController.text;
            final qArtist = _artistController.text;
            await ref.read(musixmatchResultsProvider.notifier).searchTracks(qTrack, qArtist);
          }
        )
      ],
    );
  }
}
