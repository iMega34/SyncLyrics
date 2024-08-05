
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/extensions.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';

class LineContent extends ConsumerStatefulWidget {
  /// The content of a single line of lyrics
  /// 
  /// Allows the user to edit the timestamp and lyrics of the line.
  /// 
  /// Parameters:
  /// - [index] is the index of the line in the list of lyrics
  /// - [timestamp] is the timestamp of the line without square braces
  /// - [content] is the lyrics of the line
  const LineContent({
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
  ConsumerState<LineContent> createState() => _LineContentState();
}

class _LineContentState extends ConsumerState<LineContent> {
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;
  late TextEditingController _millisecondsController;
  late TextEditingController _contentController;
  final _minutesNode = FocusNode();
  final _secondsNode = FocusNode();
  final _millisecondsNode = FocusNode();
  final _contentNode = FocusNode();

  // Focus node for all the text fields
  final _focusScopeNode = FocusScopeNode();
  final _focusNode = FocusNode();
  int _focusedNode = 0;

  // List of focus nodes for the text fields
  List<FocusNode> _focusNodes = [];
  List<TextEditingController> _controllers = [];

  String _initialTimestamp = "";
  String _initialContent = "";

  @override
  void initState() {
    super.initState();
    final splittedTimestamp = widget.timestamp.split(RegExp(r"[.:]"));
    _minutesController = TextEditingController(text: splittedTimestamp[0]);
    _secondsController = TextEditingController(text: splittedTimestamp[1]);
    _millisecondsController = TextEditingController(text: splittedTimestamp[2]);
    _contentController = TextEditingController(text: widget.content);
    _focusNodes = [_minutesNode, _secondsNode, _millisecondsNode, _contentNode];
    _controllers = [_minutesController, _secondsController, _millisecondsController, _contentController];

    _initialTimestamp = widget.timestamp;
    _initialContent = widget.content;

    _minutesNode.addListener(() => _formatTimestampPart(_minutesController, _minutesNode));
    _secondsNode.addListener(() => _formatTimestampPart(_secondsController, _secondsNode));
    _millisecondsNode.addListener(() => _formatTimestampPart(_millisecondsController, _millisecondsNode));
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    _millisecondsController.dispose();
    _contentController.dispose();
    _minutesNode.dispose();
    _secondsNode.dispose();
    _millisecondsNode.dispose();
    _contentNode.dispose();
    _focusScopeNode.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Format the timestamp part
  /// 
  /// Ensures that the timestamp part is always two digits long. Filling empty spaces
  /// with zeros.
  /// 
  /// Parameters:
  /// - [controller] is the [TextEditingController] of the timestamp part
  /// - [node] is the [FocusNode] of the timestamp part
  void _formatTimestampPart(TextEditingController controller, FocusNode node) {
    if (!node.hasFocus) {
      setState(() => controller.text = controller.text.padLeft(2, "0"));
    }
  }

  /// Save the line
  /// 
  /// Call the corresponding method in the `workspaceProvider` to save the line after
  /// the text field loses focus, i.e., the user has finished editing the line.
  /// 
  /// Parameters:
  /// - [hasFocus] is a boolean indicating whether the text field has focus
  void _saveLine(bool hasFocus) {
    // Return if the text field has focus
    if (hasFocus) return;

    // Get the current timestamp and content
    final timestamp = "${_minutesController.text}:${_secondsController.text}:${_millisecondsController.text}";
    final content = _contentController.text;

    // Only save the line if the timestamp or content has changed
    if (_initialTimestamp != timestamp || _initialContent != content) {
      ref.read(workspaceProvider.notifier).saveLine(widget.index, {timestamp : content});
      _initialTimestamp = timestamp;
      _initialContent = content;
    }
  }

  /// Handle key events
  /// 
  /// Used for navigating between the text fields using the arrow keys.
  /// 
  /// Parameters:
  /// - [event] is the key event to handle
  void _handleKey(KeyEvent event) {
    // Return if the key is not pressed
    if (event is! KeyDownEvent) return;

    // Get the current controller, position, and text length
    final currentController = _controllers[_focusedNode];
    final currentPosition = currentController.selection.baseOffset;
    final textLength = currentController.text.length;

    // Define conditions for navigating between the text fields
    final isLeftArrowPressed = event.logicalKey == LogicalKeyboardKey.arrowLeft;
    final isRightArrowPressed = event.logicalKey == LogicalKeyboardKey.arrowRight;
    final hasPreviousNode = _focusedNode > 0;
    final hasNextNode = _focusedNode < _focusNodes.length - 1;
    final isAtStartPosition = currentPosition == 0;
    final isAtEndPosition = currentPosition == textLength;

    // Navigate to the previous node if the left arrow key is pressed and the cursor is
    // at the start position
    if (isLeftArrowPressed && hasPreviousNode && isAtStartPosition) {
      _focusedNode--;
      _controllers[_focusedNode].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[_focusedNode].text.length)
      );
    }

    // Navigate to the next node if the right arrow key is pressed and the cursor is
    // at the end position
    if (isRightArrowPressed && hasNextNode && isAtEndPosition) {
      _focusedNode++;
      _controllers[_focusedNode].selection = TextSelection.fromPosition(
        const TextPosition(offset: 0)
      );
    }

    // Focus the corresponding node
    _focusNodes[_focusedNode].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final timestampPartTextWidth = "00".textWidth * 1.5;
    return Expanded(
      child: FocusScope(
        node: _focusScopeNode,
        onFocusChange: (bool hasFocus) => _saveLine(hasFocus),
        child: KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (KeyEvent event) => _handleKey(event),
          child: Row(
            children: [
              // Minutes text field
              SizedBox(
                width: timestampPartTextWidth,
                child: TextField(
                  focusNode: _minutesNode,
                  controller: _minutesController,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, counterText: ""),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 2,
                  onTap: () => setState(() => _focusedNode = 0),
                )
              ),
              const Text(":"),
              // Seconds text field
              SizedBox(
                width: timestampPartTextWidth,
                child: TextField(
                  focusNode: _secondsNode,
                  controller: _secondsController,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, counterText: ""),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 2,
                  onTap: () => setState(() => _focusedNode = 1),
                )
              ),
              const Text(":"),
              // Milliseconds text field
              SizedBox(
                width: timestampPartTextWidth,
                child: TextField(
                  focusNode: _millisecondsNode,
                  controller: _millisecondsController,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, counterText: ""),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 2,
                  onTap: () => setState(() => _focusedNode = 2),
                )
              ),
              const SizedBox(width: 5),
              // Content text field
              Expanded(
                child: TextField(
                  focusNode: _contentNode,
                  controller: _contentController,
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                  onTap: () => setState(() => _focusedNode = 3),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
