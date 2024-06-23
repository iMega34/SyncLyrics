
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/custom_themes.dart';

class Neomorphic extends StatelessWidget {
  const Neomorphic({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<CustomAppTheme>()!;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: appColors.element,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: appColors.externalShadow,
              offset: const Offset(4, 4),
              blurRadius: 10,
              spreadRadius: 1
            ),
            BoxShadow(
              color: appColors.internalShadow,
              offset: const Offset(-4, -4),
              blurRadius: 10,
              spreadRadius: 1
            ),
          ]
        ),
        child: child,
      ),
    );
  }
}
