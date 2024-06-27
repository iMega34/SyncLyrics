
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class Neumorphic extends StatelessWidget {
  /// Simple template for neumorphic widgets
  /// 
  /// Parameters:
  /// - [child] is the widget to be displayed
  const Neumorphic({super.key, required this.child, this.color});

  // Class attributes
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<CustomAppTheme>()!;
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: appColors.externalShadow,
            offset: const Offset(5, 5),
            blurRadius: 15,
          ),
          BoxShadow(
            color: appColors.internalShadow,
            offset: const Offset(-5, -5),
            blurRadius: 15,
          ),
        ]
      ),
      child: child,
    );
  }
}
