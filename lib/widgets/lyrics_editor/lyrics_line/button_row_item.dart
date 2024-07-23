
import 'package:flutter/material.dart';

class ButtonRowItem extends StatelessWidget {
  /// A single button item in the button row
  /// 
  /// Parameters:
  /// - [icon] is the icon to display in the button
  /// - [onPressed] is the function to call when the button is pressed
  /// - [tooltipText] is the text to display when the button is hovered over
  /// - [borderRadius] is the border radius of the button
  /// - [iconSize] is the size of the icon
  /// - [size] is the size of the button
  /// - [margin] is the margin around the button
  /// - [color] is the color of the button
  const ButtonRowItem({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltipText,
    this.borderRadius = 5,
    this.iconSize = 16,
    this.size = 20,
    this.margin,
    this.color,
  });

  // Class attributes
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltipText;
  final double borderRadius;
  final double iconSize;
  final double size;
  final EdgeInsets? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: tooltipText,
        // Show the tooltip after 1 second
        waitDuration: const Duration(seconds: 1),
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            margin: margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: color
            ),
            child: Icon(icon, size: iconSize)
          ),
        ),
      ),
    );
  }
}
