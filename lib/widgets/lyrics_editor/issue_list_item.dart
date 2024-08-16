
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';

class IssueListItem extends StatelessWidget {
  /// Represents an issue list item
  /// 
  /// This widget displays an issue found in the workspace, by showing the issue content
  /// and a colored indicator on the left side of the content to visually indicate the issue
  /// 
  /// Parameters:
  /// - [content] is the content of the issue
  /// - [color] is the color of the indicator
  const IssueListItem({super.key, required this.content, required this.color});

  // Class attributes
  final String content;
  final Color color;

  /// Creates a duplicate line item with the given index and its its corresponding color
  /// 
  /// Parameters:
  /// - [context] is the build context
  /// - [index] is the index of the duplicate line
  static IssueListItem duplicateLine(BuildContext context, int index) {
    final duplicateLineColor = Theme.of(context).extension<ConflictIndicatorsTheme>()!.duplicated;
    return IssueListItem(content: "Duplicate found in line $index", color: duplicateLineColor);
  }

  /// Creates an unordered line item with the given index and its its corresponding color
  /// 
  /// Parameters:
  /// - [context] is the build context
  /// - [index] is the index of the unordered line
  static IssueListItem unorderedLine(BuildContext context, int index) {
    final unorderedLineColor = Theme.of(context).extension<ConflictIndicatorsTheme>()!.unordered;
    return IssueListItem(content: "Unordered found in line $index", color: unorderedLineColor);
  }

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 10, color: color),
            ),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 10),
                child: Text(content),
              )
            ),
          ],
        ),
      )
    );
  }
}
