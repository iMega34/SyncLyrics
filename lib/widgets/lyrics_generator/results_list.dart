
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/providers/musixmatch_results_provider.dart';
import 'package:sync_lyrics/widgets/lyrics_generator/result_item.dart';

class ResultsList extends ConsumerStatefulWidget {
  /// List displaying the search results from Musixmatch provider
  const ResultsList({super.key});

  @override
  ConsumerState<ResultsList> createState() => _ResultsListState();
}

class _ResultsListState extends ConsumerState<ResultsList> {
  @override
  Widget build(BuildContext context) {
    final results = ref.watch(musixmatchResultsProvider).results;

    if (results == null) {
      return const Expanded(child: Center(child: Text("No results to display. Try looking for a song")));
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 5 / 6
          ),
          itemCount: results.length,
          itemBuilder: (context, index) => ResultItem(result: results[index]),
        ),
      ),
    );
  }
}
