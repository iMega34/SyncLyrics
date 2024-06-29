
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/neumorphic/neumorphic_togglable_button.dart';

class NeumorphicSidebar extends StatefulWidget {
  const NeumorphicSidebar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected
  });

  final int selectedIndex;
  final List<Destination> destinations;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<NeumorphicSidebar> createState() => _NeumorphicSidebarState();
}

class _NeumorphicSidebarState extends State<NeumorphicSidebar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          for (int i = 0; i < widget.destinations.length; i++)
            NeumorphicTogglableButton(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              enabled: widget.selectedIndex != i,
              locked: widget.selectedIndex == i,
              onPressed: () => widget.onDestinationSelected(i),
              child: widget.selectedIndex == i
                ? widget.destinations[i].selectedLabel
                : widget.destinations[i].label,
            )
        ],
      )
    );
  }
}

class Destination {
  const Destination({required this.label, Widget? selectedLabel}) : selectedLabel = selectedLabel ?? label;

  final Widget label;
  final Widget selectedLabel;
}
