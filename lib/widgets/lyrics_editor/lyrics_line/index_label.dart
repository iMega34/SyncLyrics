
import 'package:flutter/material.dart';

import 'package:sync_lyrics/extensions.dart';
import 'package:sync_lyrics/utils/custom_themes.dart';

class IndexLabel extends StatelessWidget {
  /// A label widget that displays the index of the line and its status
  /// 
  /// This label is positioned on the left side of the line. It indicates whether
  /// the line is duplicated or out of order by changing its color accordingly.
  /// 
  /// Parameters:
  /// - [index] is the index of the line
  /// - [isDuplicated] is whether the line is a duplicate of another line
  /// - [isUnordered] is whether the line is out of order
  const IndexLabel({
    super.key,
    required this.index,
    required this.isDuplicated,
    required this.isUnordered
  });

  // Class attributes
  final int index;
  final bool isDuplicated;
  final bool isUnordered;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.black54);
    final conflictIndicatorsColors = Theme.of(context).extension<ConflictIndicatorsTheme>()!;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(25)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  if (isDuplicated) Expanded(child: Container(color: conflictIndicatorsColors.duplicated)),
                  if (isUnordered) Expanded(child: Container(color: conflictIndicatorsColors.unordered)),
                ],
              ),
            ),
            Container(
              width: "000000".textWidth,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 5),
              child: Text("${index + 1}", style: textTheme)
            ),
          ],
        ),
      ),
    );
  }
}
