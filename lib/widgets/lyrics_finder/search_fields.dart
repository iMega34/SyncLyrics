
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

  /// Handles error status codes
  /// 
  /// Displays a [CustomSnackBar] based on the status code to alert the user of an error
  /// 
  /// Parameters:
  /// - [statusCode] is the status code
  void _handleStatusCode(int statusCode) {
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
          )
        ),
        Expanded(
          child: NeumorphicTextField(
            label: "Track",
            controller: _trackController,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            onChanged: (String text) => notifier.setTrack(text),
          )
        ),
        NeumorphicButton(
          label: "Search",
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          onPressed: () async {
            final statusCode = await notifier.searchTracks();
            _handleStatusCode(statusCode);
          }
        )
      ],
    );
  }
}
