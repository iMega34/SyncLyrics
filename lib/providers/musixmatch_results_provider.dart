
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/musixmatch_api_key.dart';

/// Musixmatch result type
typedef MusixmatchResult = Map<String, String>;

class MusixmatchResultsState {
  /// State for the Musixmatch results provider
  /// 
  /// Parameters:
  /// - [results] is the list of results from the search
  MusixmatchResultsState({this.results});

  // Class attributes
  final List<MusixmatchResult>? results;

  /// Copy the current state with new values
  /// 
  /// Parameters:
  /// - [results] is the list of results from the search
  MusixmatchResultsState copyWith({List<MusixmatchResult>? results})
    => MusixmatchResultsState(results: results ?? this.results);
}

class MusixmatchResultsNotifier extends StateNotifier<MusixmatchResultsState> {
  /// Musixmatch provider
  /// 
  /// Musixmatch client to search for tracks using the Musixmatch public API
  /// 
  /// The initial state is an empty state, with no  results
  MusixmatchResultsNotifier() : super(MusixmatchResultsState());

  /// Search for tracks using the Musixmatch API
  /// 
  /// The results are stored in the state as a [List] of [Map]s with the track, artist,
  /// album and Musixmatch track ID as [String]s
  /// 
  /// Parameters:
  /// - [qTrack] is the track name to search for
  /// - [qArtist] is the artist name to search for
  Future<void> searchTracks(String qTrack, String qArtist) async {
    // Uses the 'track.search' endpoint from the Musixmatch API to search for tracks
    final String matchTrackURL = Uri.encodeFull("https://api.musixmatch.com/ws/1.1/track.search?apikey=$musixmatchApiKey&q_track=$qTrack&q_artist=$qArtist");

    // Fetch the data from the API and decode it as Map<String, dynamic>
    final response = await http.get(Uri.parse(matchTrackURL));
    final Map<String, dynamic> data = json.decode(response.body);

    // Parse the data from the 'message/body/track_list' path and store it in a list as a MusixmatchResult (Map<String, String>)
    final List<MusixmatchResult> results = [];
    for (final (result as Map<String, dynamic>) in data["message"]["body"]["track_list"] as List) {
      final musixmatchResult = _fetchTrackInfo(result);
      results.add(musixmatchResult);
    }

    // Update the state with the results from the search
    state = state.copyWith(results: results);
  }

  /// Fetch the relevant information retrived from the Musixmatch API
  /// 
  /// Parameters:
  /// - [trackListElement] is the element from the track list
  /// 
  /// Returns:
  /// - A map with the track, artist, album and Musixmatch track ID
  MusixmatchResult _fetchTrackInfo(Map<String, dynamic> trackListElement) {
    final Map<String, dynamic> track = trackListElement["track"];

    // If there are no lyrics available, return a map with a message instead
    // of the URL to the lyrics in Musixmatch
    if (track["has_subtitles"] == 0) {
      return {
        "track" : track["track_name"] ?? "Unknown",
        "artist" : track["artist_name"] ?? "Unknown",
        "album" : track["album_name"] ?? "Unknown",
        "track_id" : ""
      };
    }

    return {
      "track" : track["track_name"] ?? "Unknown",
      "artist" : track["artist_name"] ?? "Unknown",
      "album" : track["album_name"] ?? "Unknown",
      "track_id" : track["track_id"].toString()
    };
  }
}

/// Musixmatch provider
/// 
/// Musixmatch client to search for tracks using the Musixmatch public API
/// 
/// The initial state is an empty state, with no results
final musixmatchResultsProvider = StateNotifierProvider<MusixmatchResultsNotifier, MusixmatchResultsState>(
  (ref) => MusixmatchResultsNotifier()
);
