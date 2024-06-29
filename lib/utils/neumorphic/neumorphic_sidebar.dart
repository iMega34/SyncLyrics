
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/neumorphic/neumorphic_togglable_button.dart';

class NeumorphicSidebar extends StatefulWidget {
  /// Sidebar for changing screens
  /// 
  /// This widget is a navigation rail that allows the user to switch between
  /// different screens. In order to work properly, a [List] of [Destination]s
  /// must be provided.
  /// 
  /// Parameters:
  /// - [selectedIndex] is the index of the selected destination
  /// - [destinations] is the list of destinations to display
  /// - [onDestinationSelected] is the function to call when a destination is selected
  const NeumorphicSidebar({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected
  });

  // Class attributes
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
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              enabled: widget.selectedIndex != i,
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
  /// Destination for the sidebar
  /// 
  /// Represents a destination in the sidebar. Must be provided as an element
  /// in the list of destinations in the [NeumorphicSidebar] widget.
  /// 
  /// Parameters:
  /// - [label] is the widget to display when the destination is not selected
  /// - [selectedLabel] is the widget to display when the destination is selected
  const Destination({required this.label, Widget? selectedLabel})
    // If [selectedLabel] is not provided, use [label]
    : selectedLabel = selectedLabel ?? label;

  // Class attributes
  final Widget label;
  final Widget selectedLabel;
}
