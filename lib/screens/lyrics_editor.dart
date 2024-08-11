
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/workspace.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_info.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/toolbar.dart';

class LyricsEditorScreen extends StatelessWidget {
  const LyricsEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: FocusScope.of(context).unfocus,
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Neumorphic(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    LyricsInfo(),
                    SizedBox(height: 10),
                    Workspace()
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: Toolbar())
          ],
        ),
      ),
    );
  }
}
