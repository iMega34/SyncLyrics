
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line/button_row.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line/index_label.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line/line_content.dart';

class LyricsLine extends ConsumerStatefulWidget {
  /// A single line of lyrics with its timestamp
  /// 
  /// Lets the user select a line and edit the timestamp and lyrics, as well as
  /// other actions like deleting or moving the line.
  /// 
  /// Parameters:
  /// - [index] is whether the line is selected or not
  /// - [timestamp] is the timestamp of the line without square braces
  /// - [content] is the lyrics of the line
  /// - [isDuplicated] is whether the line is a duplicate of another line
  /// - [isUnordered] is whether the line is out of order
  const LyricsLine({
    super.key,
    required this.index,
    required this.timestamp,
    required this.content,
    required this.isDuplicated,
    required this.isUnordered,
  });

  // Class attributes
  final int index;
  final String timestamp;
  final String content;
  final bool isDuplicated;
  final bool isUnordered;

  @override
  ConsumerState<LyricsLine> createState() => _LyricsLineState();
}

class _LyricsLineState extends ConsumerState<LyricsLine> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Handles key events
  /// 
  /// Used to select the previous or next line of lyrics using the up and down
  /// 
  /// Parameters:
  /// - [event] is the keyboard event
  void _handleKey(KeyEvent event) {
    // Return if the key is not pressed
    if (event is! KeyDownEvent) return;

    // Get the parsed lyrics length
    final parsedLyricsLength = ref.read(workspaceProvider).parsedLyrics!.length;

    // Define conditions for selecting the previous or next line
    final isUpArrowPressed = event.logicalKey == LogicalKeyboardKey.arrowUp;
    final isDownArrowPressed = event.logicalKey == LogicalKeyboardKey.arrowDown;
    final hasPreviousLine = widget.index > 0;
    final hasNextLine = widget.index < parsedLyricsLength - 1;

    // Select the previous or next line if the up arrow is pressed and there is
    // a previous line to select
    if (isUpArrowPressed && hasPreviousLine) {
      ref.read(workspaceProvider.notifier).selectLine(widget.index - 1);
    }

    // Select the next line if the down arrow is pressed and there is a next line
    // to select
    if (isDownArrowPressed && hasNextLine) {
      ref.read(workspaceProvider.notifier).selectLine(widget.index + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final selectedColor = theme.extension<CustomAppTheme>()!.selected;
    final selectedLine = ref.watch(workspaceProvider).selectedLine;
    final isSelected = selectedLine == widget.index;

    if (isSelected) _focusNode.requestFocus();

    return FocusScope(
      node: FocusScopeNode(),
      child: TapRegion(
        onTapInside: (_) {
          ref.read(workspaceProvider.notifier).selectLine(widget.index);
          _focusNode.requestFocus();
        },
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (KeyEvent event) => _handleKey(event),
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
                // Line content
                child: Row(
                  children: [
                    IndexLabel(index: widget.index, isDuplicated: widget.isDuplicated, isUnordered: widget.isUnordered),
                    LineContent(index: widget.index, timestamp: widget.timestamp, content: widget.content),
                  ],
                )
              ),
              // Top button row
              Positioned(
                top: 10,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: isSelected ? const ButtonRow() : const SizedBox.shrink(),
                ),
              ),
              // Lower button row
              Positioned(
                bottom: 10,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: isSelected ? const ButtonRow(lowerRow: true) : const SizedBox.shrink(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
