
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sync_lyrics/providers/settings_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/utils/neumorphic/neumorphic_button.dart';

class DownloadDirectoryField extends ConsumerStatefulWidget {
  /// Represents a field to input the download directory
  /// 
  /// The download directory is used to store the synchronized lyrics files
  /// downloaded from the app
  const DownloadDirectoryField({super.key});

  @override
  ConsumerState<DownloadDirectoryField> createState() => _DownloadDirectoryFieldState();
}

class _DownloadDirectoryFieldState extends ConsumerState<DownloadDirectoryField> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final downloadDirectory = ref.read(settingsProvider).downloadDirectory;
    controller = TextEditingController(text: downloadDirectory);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// Select a directory to save the synchronized lyrics
  /// 
  /// Opens a dialog to select a directory to save the synchronized lyrics
  void _selectDownloadDirectory() async {
    // Get the initial directory to open the dialog, and show a dialog to select a directory
    final initDirectory = ref.read(settingsProvider).downloadDirectory;
    final downloadDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select the directory to save synchronized lyrics",
      initialDirectory: initDirectory,
      lockParentWindow: true
    );

    // If the user cancels the dialog, return
    if (downloadDirectory == null) return;

    // Save the selected directory in the app settings
    ref.read(settingsProvider.notifier).saveDownloadDirectory(downloadDirectory);
    controller.text = downloadDirectory;
  }

  @override
  Widget build(BuildContext context) {
    controller.text = ref.watch(settingsProvider).downloadDirectory!;
    return Row(
      children: [
        Expanded(
          child: Neumorphic(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Download directory",
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              readOnly: true,
            )
          )
        ),
        NeumorphicButton(
          label: "Select directory",
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          onPressed: _selectDownloadDirectory
        ),
        NeumorphicButton(
          label: "Reset directory",
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          onPressed: ref.read(settingsProvider.notifier).resetDownloadDirectory
        ),
      ],
    );
  }
}
