
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class Neumorphic extends StatelessWidget {
  /// Simple template for neumorphic widgets
  /// 
  /// Parameters:
  /// - [child] is the widget to be displayed
  /// - [color] is the background color of the widget
  /// - [margin] is the margin of the widget
  /// - [padding] is the padding of the widget
  /// - [borderRadius] is the border radius of the widget
  const Neumorphic({
    super.key,
    required this.child,
    this.color,
    this.margin,
    this.padding,
    this.borderRadius
  });

  // Class attributes
  final Widget child;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<CustomAppTheme>()!;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).scaffoldBackgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(15),
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
