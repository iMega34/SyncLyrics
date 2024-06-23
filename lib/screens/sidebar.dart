
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/routes/router.dart';

class Sidebar extends ConsumerStatefulWidget {
  /// Sidebar for changing screens
  /// 
  /// This widget is a navigation rail that allows the user to switch between
  /// different screens.
  const Sidebar({super.key});

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  int _selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _selectedIdx,
      labelType: NavigationRailLabelType.selected,
      onDestinationSelected: (int index) => setState(() {
        _selectedIdx = index;
        Routes.changeScreen(context, _selectedIdx);
      }),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text("Home")
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: Text("Settings")
        ),
      ],
    );
  }
}
