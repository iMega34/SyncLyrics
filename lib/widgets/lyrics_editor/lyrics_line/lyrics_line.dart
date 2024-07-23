
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line/button_row.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line/line_content.dart';

class LyricsLine extends ConsumerStatefulWidget {
  /// A single line of lyrics with its timestamp
  /// 
  /// Lets the user select a line and edit the timestamp and lyrics, as well as
  /// other actions like deleting or moving the line.
  /// 
  /// Parameters:
  /// - [index] is whether the line is selected or not
  /// - [timestamp] is the timestamp of the line
  /// - [content] is the lyrics of the line
  const LyricsLine({
    super.key,
    required this.index,
    required this.timestamp,
    required this.content
  });

  // Class attributes
  final int index;
  final String timestamp;
  final String content;

  @override
  ConsumerState<LyricsLine> createState() => _LyricsLineState();
}

class _LyricsLineState extends ConsumerState<LyricsLine> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final selectedColor = theme.extension<CustomAppTheme>()!.selected;
    final selectedLine = ref.watch(workspaceProvider).selectedLine;
    final isSelected = selectedLine == widget.index;

    return FocusScope(
      onFocusChange: (bool hasFocus) => hasFocus
        ? ref.read(workspaceProvider.notifier).selectLine(widget.index)
        : ref.read(workspaceProvider.notifier).deselectLine(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            curve: Curves.linearToEaseOut,
            duration: const Duration(milliseconds: 500),
            margin: isSelected ? const EdgeInsets.symmetric(vertical: 20) : const EdgeInsets.symmetric(),
            padding: isSelected ? const EdgeInsets.symmetric(horizontal: 10, vertical: 20) : const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: isSelected ? BorderRadius.circular(10) : BorderRadius.circular(0),
              color: isSelected ? selectedColor : backgroundColor
            ),
            child: LineContent(index: widget.index, timestamp: widget.timestamp, content: widget.content)
          ),
          // Display the button row when the line is selected
          Positioned(
            top: 10,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: isSelected ? const ButtonRow() : const SizedBox.shrink(),
            ),
          ),
          Positioned(
            bottom: 10,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: isSelected ? const ButtonRow(lowerRow: true) : const SizedBox.shrink(),
            ),
          )
        ],
      ),
    );
  }
}
