
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line.dart';
import 'package:sync_lyrics/providers/musixmatch_synced_lyrics_provider.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';

class Workspace extends ConsumerStatefulWidget {
  /// Workspace for displaying and editing synced lyrics, used in the `LyricsEditorScreen`.
  /// 
  /// This widget displays the synced lyrics in a scrollable list view. Supports
  /// editing of the lyrics and timestamps by interacting with the `workspaceProvider`.
  /// 
  /// For more information regarding the `workspaceProvider`, refer to the
  /// `workspace_provider.dart` file.
  const Workspace({super.key});

  @override
  ConsumerState<Workspace> createState() => _TextViewerState();
}

class _TextViewerState extends ConsumerState<Workspace> {

  @override
  void initState() {
    super.initState();
    final parsedLyrics = ref.read(syncedLyricsProvider).parsedLyrics;
    // Load the lyrics into the workspace provider if available
    if (parsedLyrics != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(workspaceProvider.notifier).loadLyrics(parsedLyrics)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final parsedLyrics = ref.watch(syncedLyricsProvider).parsedLyrics;

    // Display a message if there are no synced lyrics available from the `parsedLyricsProvider`
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
        child: TapRegion(
          onTapOutside: (_) => ref.read(workspaceProvider.notifier).deselectLine(),
          child: ListView.builder(
            itemCount: parsedLyrics.length,
            itemBuilder: (_, index) => LyricsLine(
              index: index,
              timestamp: parsedLyrics[index].keys.first,
              lyrics: parsedLyrics[index].values.first
            ),
          ),
        ),
      ),
    );
  }
}
