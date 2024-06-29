

import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class NeumorphicTogglableButton extends StatefulWidget {
  /// Togglable button that immplements neumorphic design
  /// 
  /// Parameters:
  /// - [label] is the text to display in the button
  /// - [child] is the widget to display in the button
  /// - [onPressed] is the function to call when the button is pressed
  /// - [margin] is the margin of the button
  /// - [padding] is the padding of the button
  /// - [centerContent] is whether to center the content of the button
  /// - [enabled] is whether the button is enabled
  const NeumorphicTogglableButton({
    super.key,
    this.label,
    this.child,
    required this.onPressed,
    this.margin,
    this.padding,
    this.centerContent = true,
    this.enabled = true,
    this.locked = false
  });

  // Class attributes
  final String? label;
  final Widget? child;
  final VoidCallback onPressed;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool centerContent;
  final bool enabled;
  final bool locked;

  @override
  State<NeumorphicTogglableButton> createState() => _NeumorphicTogglableButtonState();
}

class _NeumorphicTogglableButtonState extends State<NeumorphicTogglableButton> {
  bool _isPressed = false;

  @override
  void didUpdateWidget(covariant NeumorphicTogglableButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.locked && _isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<CustomAppTheme>()!;
    Offset distance = _isPressed ? const Offset(2, 2) : const Offset(5, 5);
    double blur = _isPressed ? 5 : 15;

    if (widget.label != null && widget.child != null) {
      throw ArgumentError("Only one of 'label' or 'child' can be provided");
    }

    return GestureDetector(
      onTap: widget.enabled
        ? () {
            widget.onPressed();
            setState(() => _isPressed = !_isPressed);
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
              inset: _isPressed
            ),
            BoxShadow(
              color: appColors.internalShadow,
              offset: -distance,
              blurRadius: blur,
              inset: _isPressed
            ),
          ]
        ),
        child: widget.child ?? Text(widget.label!),
      ),
    );
  }
}
