
import 'package:flutter/material.dart';

import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/toolbar.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/workspace.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/lyrics_info.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/workspace_status_viewer.dart';

class LyricsEditorScreen extends StatelessWidget {
  /// Represents the lyrics editor screen
  /// 
  /// This widget displays the lyrics editor screen, which contains the lyrics information,
  /// the workspace where the lyrics are edited, the toolbar to interact with the workspace,
  /// and the workspace status viewer to display the issues found in the workspace
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
            // Lyrics information and workspace
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
            // Toolbar and workspace status viewer
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Toolbar(),
                  SizedBox(height: 10),
                  WorkspaceStatusViewer()
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
