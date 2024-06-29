
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/routes/router.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_sidebar.dart';

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
