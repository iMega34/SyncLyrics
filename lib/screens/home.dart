
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_lyrics/providers/screen_provider.dart';

import 'package:sync_lyrics/screens/sidebar.dart';

final screens = [
  Expanded(child: Container(color: Colors.red)),
  Expanded(child: Container(color: Colors.blue)),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final index = ref.watch(screenIndexProvider).index!;
    return Row(
      children: [
        const Sidebar(),
        screens[index]
      ],
    );
  }
}
