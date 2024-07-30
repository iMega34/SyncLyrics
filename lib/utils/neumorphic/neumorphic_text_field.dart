
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class NeumorphicTextField extends StatelessWidget {
  /// Text field that implements neumorphic design
  /// 
  /// Parameters:
  /// - [label] is the label for the text field
  /// - [controller] is the controller for the text field
  /// - [margin] is the margin for the text field
  /// - [onChanged] is the function to call when the text field changes
  const NeumorphicTextField({
    super.key,
    required this.label,
    required this.controller,
    this.margin,
    this.onChanged
  });

  // Class attributes
  final String label;
  final TextEditingController controller;
  final EdgeInsets? margin;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<CustomAppTheme>()!;
    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: const OutlineInputBorder(borderSide: BorderSide.none),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
