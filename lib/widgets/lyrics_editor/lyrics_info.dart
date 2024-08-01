
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/providers/workspace_provider.dart';

class LyricsInfo extends ConsumerStatefulWidget {
  /// Displays the track and artist of the synced lyrics, used in the `LyricsEditorScreen`
  /// 
  /// Listens to the `syncedLyricsProvider` to display the information related to the
  /// synced lyrics after fetching information form the track, either from the Musixmatch API
  /// or from a provided LRC file.
  /// 
  /// For more information regarding the `syncedLyricsProvider`, refer to the
  /// `musixmatch_synced_lyrics_provider.dart` file.
  const LyricsInfo({super.key});

  @override
  ConsumerState<LyricsInfo> createState() => _LyricsInfoState();
}

class _LyricsInfoState extends ConsumerState<LyricsInfo> {
  late TextEditingController _trackController;
  late TextEditingController _artistController;

  @override
  void initState() {
    super.initState();
    final lyricsInfo = ref.read(workspaceProvider);
    _trackController = TextEditingController(text: lyricsInfo.track ?? "No track");
    _artistController = TextEditingController(text: lyricsInfo.artist ?? "No artist");
  }

  @override
  void dispose() {
    _trackController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(workspaceProvider.notifier);
    return Column(  
      children: [
        // Display the track and artist of the synced lyrics, if available
        TextField(
          controller: _trackController, 
          textAlign: TextAlign.center,
          style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            isDense: true
          ),
          onChanged: (String text) => notifier.setTrack(text),
        ),
        TextField(
          controller: _artistController,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            isDense: true
          ),
          onChanged: (String text) => notifier.setArtist(text),
        ),
      ],
    );
  }
}
