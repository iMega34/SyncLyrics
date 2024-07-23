
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/providers/workspace_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line/lyrics_line.dart';

class Workspace extends ConsumerWidget {
  /// Workspace for displaying and editing synced lyrics, used in the `LyricsEditorScreen`.
  /// 
  /// This widget displays the synced lyrics in a scrollable list view. Supports
  /// editing of the lyrics and timestamps by interacting with the `workspaceProvider`.
  /// 
  /// For more information regarding the `workspaceProvider`, refer to the
  /// `workspace_provider.dart` file.
  const Workspace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final parsedLyrics = ref.watch(workspaceProvider).parsedLyrics;

    // Display a message if there are no synced lyrics available from the `workspaceProvider`
    if (parsedLyrics == null) {
      return Expanded(
        child: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("No synced lyrics to display", style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Search for a song in the 'Lyrics Finder' screen"),
            const Text("or upload an LRC file from your device")
          ],
        ))
      );
    }

    return Expanded(
      child: ScrollConfiguration(
        behavior: const ScrollBehavior(),
        child: ListView.builder(
          itemCount: parsedLyrics.length,
          itemBuilder: (_, index) => LyricsLine(
            key: ValueKey("${parsedLyrics[index].keys.first}-${parsedLyrics[index].values.first}"),
            timestamp: parsedLyrics[index].keys.first,
            content: parsedLyrics[index].values.first,
            index: index,
          )
        ),
      ),
    );
  }
}
