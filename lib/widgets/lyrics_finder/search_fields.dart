
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_snack_bar.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_text_field.dart';
import 'package:sync_lyrics/providers/musixmatch_results_provider.dart';

class SearchFields extends ConsumerStatefulWidget {
  /// Search fields for the Musixmatch provider
  const SearchFields({super.key});

  @override
  ConsumerState<SearchFields> createState() => _SearchFieldsState();
}

class _SearchFieldsState extends ConsumerState<SearchFields> {
  late TextEditingController _artistController;
  late TextEditingController _trackController;

  @override
  void initState() {
    super.initState();
    final searchFields = ref.read(musixmatchResultsProvider);
    _artistController = TextEditingController(text: searchFields.artist);
    _trackController = TextEditingController(text: searchFields.track);
  }

  @override
  void dispose() {
    _artistController.dispose();
    _trackController.dispose();
    super.dispose();
  }

  /// Search for tracks with the provided artist and track
  /// 
  /// If the artist or track name is not provided, a snackbar is shown with the
  /// corresponding error message.
  void _searchTracks() async {
    final statusCode = await ref.read(musixmatchResultsProvider.notifier).searchTracks();
    // If mounted, handle the status code
    if (!mounted) return;
    switch (statusCode) {
      case 0:
        break;
      case -1:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Input error",
          message: "The artist or track name was not provided"
        );
        break;
      case -2:
        showCustomSnackBar(
          context,
          type: SnackBarType.warning,
          title: "No results",
          message: "Couldn't find any results for the provided artist and track.\nTry changing the search terms"
        );
        break;
      case -3:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "API key error",
          message: "The Musixmatch API key is not valid or wasn't provided"
        );
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: Implementar extracción de metadatos como método de búsqueda
    final notifier = ref.read(musixmatchResultsProvider.notifier);
    return Row(
      children: [
        Expanded(
          child: NeumorphicTextField(
            label: "Artist",
            controller: _artistController,
            margin: const EdgeInsets.only(right: 10),
            onChanged: (String text) => notifier.setArtist(text),
            onSubmitted: (_) => _searchTracks(),
          )
        ),
        Expanded(
          child: NeumorphicTextField(
            label: "Track",
            controller: _trackController,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            onChanged: (String text) => notifier.setTrack(text),
            onSubmitted: (_) => _searchTracks(),
          )
        ),
        NeumorphicButton(
          label: "Search",
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          onPressed: _searchTracks
        )
      ],
    );
  }
}
