
import 'package:flutter/material.dart';

import 'package:sync_lyrics/widgets/settings/api_key_field.dart';
import 'package:sync_lyrics/widgets/settings/download_directory_field.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold);
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Settings", style: style),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: const [
                ApiKeyField(),
                SizedBox(height: 20),
                DownloadDirectoryField()
              ]
            )
          )
        ],
      ),
    );
  }
}
