
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class NeumorphicButton extends StatefulWidget {
  /// Button that immplements neumorphic design
  /// 
  /// Parameters:
  /// - [label] is the text to display in the button
  /// - [child] is the widget to display in the button
  /// - [onPressed] is the function to call when the button is pressed
  /// - [margin] is the margin of the button
  /// - [padding] is the padding of the button
  /// - [centerContent] is whether to center the content of the button
  /// - [enabled] is whether the button is enabled
  /// 
  /// Only one of 'label' or 'child' can be provided
  const NeumorphicButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.color,
    this.margin,
    this.padding,
    this.borderRadius = 15,
    this.centerContent = true,
    this.enabled = true
  });

  // Class attributes
  final String? label;
  final Widget? child;
  final VoidCallback onPressed;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double borderRadius;
  final bool centerContent;
  final bool enabled;

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<CustomAppTheme>()!;
    Offset distance = isPressed ? const Offset(2, 2) : const Offset(5, 5);
    double blur = isPressed ? 5 : 15;

    if (widget.label != null && widget.child != null) {
      throw ArgumentError("Only one of 'label' or 'child' can be provided");
    }

    return Listener(
      onPointerUp: widget.enabled
        ? (event) => setState(() => isPressed = false)
        : null,
      onPointerDown: widget.enabled
        ? (event) {
            widget.onPressed();
            setState(() => isPressed = true);
          }
        : null,
      child: AnimatedContainer(
        margin: widget.margin,
        padding: widget.padding,
        duration: const Duration(milliseconds: 40),
        alignment: widget.centerContent ? Alignment.center : null,
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: appColors.externalShadow,
              offset: distance,
              blurRadius: blur,
              inset: isPressed
            ),
            BoxShadow(
              color: appColors.internalShadow,
              offset: -distance,
              blurRadius: blur,
              inset: isPressed
            ),
          ]
        ),
        child: widget.child ?? Text(widget.label!),
      ),
    );
  }
}
