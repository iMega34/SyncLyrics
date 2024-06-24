
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class NeumporhicTextField extends StatelessWidget {
  const NeumporhicTextField({super.key, required this.label, this.margin});

  final String label;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<CustomAppTheme>()!;
    return Center(
      child: Container(
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
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }
}
