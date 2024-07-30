
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';
import 'package:sync_lyrics/utils/custom_snack_bar.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_line/button_row_item.dart';

class ButtonRow extends ConsumerWidget {
  /// A row of buttons for the lyrics editor
  /// 
  /// Parameters:
  /// - [lowerRow] is whether the row is the lower row or not
  const ButtonRow({super.key, this.lowerRow = false});

  // Class attributes
  final bool lowerRow;

  /// Handles error status codes
  /// 
  /// Displays a [CustomSnackBar] based on the status code to alert the user of an error
  /// 
  /// Parameters:
  /// - [context] is the current context
  /// - [statusCode] is the status code
  /// - [message] is the message to display
  void _handleStatusCode(BuildContext context, int statusCode, {String message = "Error"}) {
    switch (statusCode) {
      case 0:
        break;
      case -1:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Selection error",
          message: "Either the selected line or the lyrics info is empty"
        );
        break;
      case -2:
        showCustomSnackBar(
          context,
          type: SnackBarType.error,
          title: "Operation error",
          message: message
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonColor = Theme.of(context).extension<CustomButtonTheme>()!;
    return Row(
      children: [
        // Move line up or down
        ButtonRowItem(
          icon: lowerRow ? Icons.arrow_drop_down : Icons.arrow_drop_up,
          margin: const EdgeInsets.only(right: 5),
          color: buttonColor.moveLine,
          tooltipText: lowerRow ? "Move line down" : "Move line up",
          onPressed: () {
            final statusCode = ref.read(workspaceProvider.notifier).moveLine(moveDown: lowerRow);
            _handleStatusCode(context, statusCode, message: lowerRow ? "Can't move line down" : "Can't move line up");
          }
        ),
        // Add space above or below
        ButtonRowItem(
          icon: Icons.add_box_outlined,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          color: buttonColor.addSpace,
          tooltipText: lowerRow ? "Add space below" : "Add space above",
          onPressed: () {
            final statusCode = ref.read(workspaceProvider.notifier).addLine(addBelow: lowerRow, addSpacer: true);
            _handleStatusCode(context, statusCode);
          }
        ),
        // Add new line above or below
        ButtonRowItem(
          icon: Icons.playlist_add_rounded,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          color: buttonColor.addLine,
          tooltipText: lowerRow ? "Add new line below" : "Add new line above",
          onPressed: () {
            final statusCode = ref.read(workspaceProvider.notifier).addLine(addBelow: lowerRow);
            _handleStatusCode(context, statusCode);
          }
        ),
        // Remove line above or below
        ButtonRowItem(
          icon: Icons.playlist_remove_rounded,
          margin: const EdgeInsets.only(left: 5),
          color: buttonColor.removeLine,
          tooltipText: lowerRow ? "Remove line below" : "Remove line above",
          onPressed: () {
            final statusCode = ref.read(workspaceProvider.notifier).removeLine(removeBelow: lowerRow);
            _handleStatusCode(context, statusCode, message: lowerRow ? "Can't remove line below" : "Can't remove line above");
          }
        )
      ],
    );
  }
}
