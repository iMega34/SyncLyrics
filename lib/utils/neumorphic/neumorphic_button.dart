
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class NeumorphicButton extends StatefulWidget {
  /// Button that immplements neumorphic design
  /// 
  /// Parameters:
  /// - [label] is the text to display in the button
  /// - [onPressed] is the function to call when the button is pressed
  /// - [margin] is the margin of the button
  const NeumorphicButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.margin,
    this.padding,
    this.centerContent = true,
    this.enabled = true
  });

  // Class attributes
  final String? label;
  final Widget? child;
  final VoidCallback onPressed;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
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
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(15),
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
