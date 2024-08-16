
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/neumorphic/neumorphic.dart';
import 'package:sync_lyrics/providers/workspace_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_editor/issue_list_item.dart';

class WorkspaceStatusViewer extends ConsumerStatefulWidget {
  /// Represents the workspace status viewer
  /// 
  /// This widget displays the issues found in the workspace, such as duplicate lines and
  /// unordered lines in as a [ListView] of [IssueListItem]s
  const WorkspaceStatusViewer({super.key});

  @override
  ConsumerState<WorkspaceStatusViewer> createState() => _WorkspaceStatusViewerState();
}

class _WorkspaceStatusViewerState extends ConsumerState<WorkspaceStatusViewer> {
  @override
  Widget build(BuildContext context) {
    final duplicateLines = ref.watch(workspaceProvider).duplicateLines;
    final unorderedLines = ref.watch(workspaceProvider).unorderedLines;
    final issuesList = [
      ...duplicateLines.map((int index) => IssueListItem.duplicateLine(context, index)),
      ...unorderedLines.map((int index) => IssueListItem.unorderedLine(context, index))
    ];

    // Display a message if there are no issues found in the workspace
    if (issuesList.isEmpty) {
      return const Expanded(
        child: Neumorphic(
          child: Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 75, color: Colors.green,),
              SizedBox(height: 10),
              Text("No issues found!")
            ],
          )),
        )
      );
    }

    return Expanded(
      child: Neumorphic(
        child: ListView.separated(
          itemCount: issuesList.length,
          padding: const EdgeInsets.all(10),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, index) => issuesList[index],
        )
      ),
    );
  }
}
