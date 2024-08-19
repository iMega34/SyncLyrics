
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';
import 'package:sync_lyrics/providers/settings_provider.dart';

class ApiKeyField extends ConsumerStatefulWidget {
  /// Represents a field to input the Musixmatch API key
  /// 
  /// The API key is used to search for tracks using the Musixmatch API, hence
  /// it is required to provide a valid API key for the search engine to work
  const ApiKeyField({super.key});

  @override
  ConsumerState<ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends ConsumerState<ApiKeyField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final apiKey = ref.read(settingsProvider).musixmatchApiKey;
    controller = TextEditingController(text: apiKey);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Neumorphic(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Musixmatch API key",
                border: OutlineInputBorder(borderSide: BorderSide.none)
              ),
            ),
          ),
        ),
        NeumorphicButton(
          label: "Save API key",
          margin: const EdgeInsets.only(left: 15),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          onPressed: () => ref.read(settingsProvider.notifier).saveMusixmatchApiKey(controller.text)
        ),
        NeumorphicButton(
          label: "Clear API key",
          margin: const EdgeInsets.only(left: 15),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          onPressed: () {
            ref.read(settingsProvider.notifier).clearMusixmatchApiKey();
            controller.clear();
          }
        ),
      ],
    );
  }
}
