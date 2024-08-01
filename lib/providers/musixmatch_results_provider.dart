
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
  /// - [track] is the track name to search for
  /// - [artist] is the artist name to search for
  /// - [results] is the list of results from the search
  MusixmatchResultsState({this.track, this.artist, this.results});

  // Class attributes
  final String? track;
  final String? artist;
  final List<MusixmatchResult>? results;

  /// Copy the current state with new values
  /// 
  /// Parameters:
  /// - [track] is the track name to search for
  /// - [artist] is the artist name to search for
  /// - [results] is the list of results from the search
  MusixmatchResultsState copyWith({
    String? track,
    String? artist,
    List<MusixmatchResult>? results
  }) => MusixmatchResultsState(
    track: track ?? this.track,
    artist: artist ?? this.artist,
    results: results ?? this.results
  );
}

class MusixmatchResultsNotifier extends StateNotifier<MusixmatchResultsState> {
  /// Musixmatch provider
  /// 
  /// Musixmatch client to search for tracks using the Musixmatch public API
  /// 
  /// The initial state is an empty state, with no  results
  MusixmatchResultsNotifier() : super(MusixmatchResultsState());

  /// Sets the track name to search for
  /// 
  /// Parameters:
  /// - [track] is the track name to search for
  void setTrack(String track) => state = state.copyWith(track: track);

  /// Sets the artist name to search for
  /// 
  /// Parameters:
  /// - [artist] is the artist name to search for
  void setArtist(String artist) => state = state.copyWith(artist: artist);

  /// Search for tracks using the Musixmatch API
  /// 
  /// The results are stored in the state as a [List] of [Map]s with the track, artist,
  /// album and Musixmatch track ID as [String]s
  /// 
  /// Returns:
  /// - `statusCode` representing if the search was successful or not as an [int]
  /// 
  /// Status codes:
  /// - `0` if the search was successful. The results are stored in the state
  /// - `-1` if the track or artist are null. No artist or track to search for
  /// - `-2` if no results were found. The search was unsuccessful
  Future<int> searchTracks() async {
    final track = state.track;
    final artist = state.artist;

    // If the track or artist are null, return an error code
    if (track == null || artist == null) {
      return -1;
    }

    // Uses the 'track.search' endpoint from the Musixmatch API to search for tracks
    final String matchTrackURL = Uri.encodeFull("https://api.musixmatch.com/ws/1.1/track.search?apikey=$musixmatchApiKey&q_track=$track&q_artist=$artist");

    // Fetch the data from the API and decode it as Map<String, dynamic>
    final response = await http.get(Uri.parse(matchTrackURL));
    final Map<String, dynamic> data = json.decode(response.body);

    // Parse the data from the 'message/body/track_list' path and store it in a list as a MusixmatchResult (Map<String, String>)
    final List<MusixmatchResult> results = [];
    for (final (result as Map<String, dynamic>) in data["message"]["body"]["track_list"] as List) {
      final musixmatchResult = _fetchTrackInfo(result);
      results.add(musixmatchResult);
    }

    // No results found
    if (results.isEmpty) {
      return -2;
    }

    // Update the state with the results from the search and return a success code
    state = state.copyWith(results: results);
    return 0;
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
