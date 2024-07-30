
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/routes/router.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_sidebar.dart';

/// Provider for the selected index of the sidebar
/// 
/// The initial value is 0, which corresponds to the [LyricsFinderScreen]
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class Sidebar extends ConsumerWidget {
  /// Sidebar for changing screens
  /// 
  /// This widget is a navigation rail that allows the user to switch between
  /// different screens.
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    return NeumorphicSidebar(
      selectedIndex: selectedIndex,
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
        ref.read(selectedIndexProvider.notifier).state = index;
        AppRouter.changeScreen(context, index);
      }
    );
  }
}
