
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/button_row.dart';

class LyricsLine extends ConsumerStatefulWidget {
  /// A single line of lyrics with its timestamp
  /// 
  /// Allows the user to edit the timestamp and lyrics of the line.
  /// 
  /// Parameters:
  /// - [index] is whether the line is selected or not
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
  late TextEditingController _timestampController;
  late TextEditingController _contentController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _timestampController = TextEditingController(text: widget.timestamp);
    _contentController = TextEditingController(text: widget.content);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _timestampController.dispose();
    _contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Get the width of the timestamp text
  /// 
  /// Parameters:
  /// - [context] is the build context
  /// 
  /// Returns:
  /// - The width of the text as a [double]
  double _getTimestampTextWidth(BuildContext context) {
    // Return 0 if the text is empty
    if (_timestampController.text.isEmpty) return 0;

    // Create a text painter to measure the width of the text
    final textPainter = TextPainter(
      text: TextSpan(text: _timestampController.text),
      textDirection: TextDirection.ltr,
      maxLines: 1
    )..layout(maxWidth: double.infinity);

    return textPainter.width * 1.4;
  }

  /// Handle the focus change event
  /// 
  /// Selects the line when the text field is focused and saves the line when
  /// the text field is unfocused.
  void _handleFocusChange() {
    _focusNode.hasFocus
      ? ref.read(workspaceProvider.notifier).selectLine(widget.index)
      : ref.read(workspaceProvider.notifier).saveLine(
          widget.index,
          {_timestampController.text: _contentController.text}
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final selectedColor = theme.extension<CustomAppTheme>()!.selected;
    final selectedLine = ref.watch(workspaceProvider).selectedLine;
    final isSelected = selectedLine == widget.index;
    final timestampTextWidth = _getTimestampTextWidth(context);

    return Focus(
      focusNode: _focusNode,
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
            child: Row(
              children: [
                SizedBox(
                  width: timestampTextWidth,
                  child: TextField(
                    controller: _timestampController,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true, counterText: ""),
                    maxLength: 10,
                  )
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(border: InputBorder.none, isDense: true)
                  )
                )
              ],
            ),
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
