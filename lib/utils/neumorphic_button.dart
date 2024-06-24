
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
  const NeumorphicButton({super.key, required this.label, required this.onPressed, this.margin});

  // Class attributes
  final String label;
  final VoidCallback onPressed;
  final EdgeInsets? margin;

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

    return Center(
      child: Listener(
        onPointerUp: (event) => setState(() => isPressed = false),
        onPointerDown: (event) => setState(() {
          isPressed = true;
          widget.onPressed;
        }),
        child: AnimatedContainer(
          margin: widget.margin,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          duration: const Duration(milliseconds: 40),
          alignment: Alignment.center,
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
          child: Text(widget.label),
        ),
      ),
    );
  }
}
