
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/button_row_item.dart';

class ButtonRow extends StatelessWidget {
  /// A row of buttons for the lyrics editor
  /// 
  /// Parameters:
  /// - [lowerRow] is whether the row is the lower row or not
  const ButtonRow({super.key, this.lowerRow = false});

  // Class attributes
  final bool lowerRow;

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).extension<CustomButtonTheme>()!;
    return Row(
      children: [
        // Move line up or down
        ButtonRowItem(
          icon: lowerRow ? Icons.arrow_drop_down : Icons.arrow_drop_up,
          margin: const EdgeInsets.only(right: 5),
          color: buttonColor.moveLine,
          tooltipText: lowerRow ? "Move line down" : "Move line up",
          onPressed: () => print('Line moved ${lowerRow ? 'down' : 'up'}')
        ),
        // Add space above or below
        ButtonRowItem(
          icon: Icons.add_box_outlined,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          color: buttonColor.addSpace,
          tooltipText: lowerRow ? "Add space below" : "Add space above",
          onPressed: () => print('Space added ${lowerRow ? 'below' : 'above'}')
        ),
        // Add new line above or below
        ButtonRowItem(
          icon: Icons.playlist_add_rounded,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          color: buttonColor.addLine,
          tooltipText: lowerRow ? "Add new line below" : "Add new line above",
          onPressed: () => print('New line added ${lowerRow ? 'below' : 'above'}')
        ),
        // Remove line above or below
        ButtonRowItem(
          icon: Icons.playlist_remove_rounded,
          margin: const EdgeInsets.only(left: 5),
          color: buttonColor.removeLine,
          tooltipText: lowerRow ? "Remove line below" : "Remove line above",
          onPressed: () => print('Line removed ${lowerRow ? 'below' : 'above'}')
        )
      ],
    );
  }
}
