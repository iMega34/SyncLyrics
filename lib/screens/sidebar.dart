
import 'package:flutter/material.dart';

import 'package:sync_lyrics/routes/router.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_sidebar.dart';

class Sidebar extends StatefulWidget {
  /// Sidebar for changing screens
  /// 
  /// This widget is a navigation rail that allows the user to switch between
  /// different screens.
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NeumorphicSidebar(
      selectedIndex: _selectedIndex,
      destinations: const [
        Destination(
          label: Icon(Icons.home_outlined),
          selectedLabel: Icon(Icons.home_rounded)
        ),
        Destination(
          label: Icon(Icons.edit_note_outlined),
          selectedLabel: Icon(Icons.edit_note_rounded)
        ),
        Destination(
          label: Icon(Icons.settings_outlined),
          selectedLabel: Icon(Icons.settings_rounded)
        )
      ],
      onDestinationSelected: (int index) {
        setState(() => _selectedIndex = index);
        AppRouter.changeScreen(context, _selectedIndex);
      }
    );
  }
}
