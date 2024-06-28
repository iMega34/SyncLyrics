
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/neumorphic.dart';

class NeumorphicFade extends StatelessWidget {
  /// Neumorphic widget with a fade effect
  /// 
  /// Parameters:
  /// - [child] is the widget to be displayed
  /// - [backgroundColor] is the color of the background
  const NeumorphicFade({super.key, required this.child, this.backgroundColor});

  // Class attributes
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      color: backgroundColor,
      borderRadius: BorderRadius.zero,
      child: ShaderMask(
        shaderCallback: (Rect rect) => LinearGradient(
          begin: Alignment.centerLeft, end: Alignment.centerRight,
          colors: [
            Colors.transparent, backgroundColor ?? Colors.white,
            backgroundColor ?? Colors.white, Colors.transparent
          ],
          stops: const [0.0, 0.1, 0.9, 1.0],
        ).createShader(rect),
        blendMode: BlendMode.dstIn,
        child: child,
      )
    );
  }
}
