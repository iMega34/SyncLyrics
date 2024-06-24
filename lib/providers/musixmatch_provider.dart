
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sync_lyrics/utils/musixmatch_api_key.dart';

typedef MusixmatchResult = Map<String, String>;

class MusixmatchState {
  /// State for the Musixmatch provider
  /// 
  /// Parameters:
  /// - [qTrack] is the track name to search for
  /// - [qArtist] is the artist name to search for
  /// - [results] is the list of results from the search
  MusixmatchState({this.qTrack, this.qArtist, this.results});

  // Class attributes
  final String? qTrack;
  final String? qArtist;
  final List<MusixmatchResult>? results;

  /// Copy the current state with new values
  /// 
  /// Parameters:
  /// - [qTrack] is the track name to search for
  /// - [qArtist] is the artist name to search for
  /// - [results] is the list of results from the search
  MusixmatchState copyWith({
    String? qTrack,
    String? qArtist,
    List<MusixmatchResult>? results
  }) {
    return MusixmatchState(
      qTrack: qTrack ?? this.qTrack,
      qArtist: qArtist ?? this.qArtist,
      results: results ?? this.results
    );
  }
}

class MusixmatchNotifier extends StateNotifier<MusixmatchState> {
  /// Musixmatch provider
  /// 
  /// The initial state is an empty state, with no track, artist or results
  MusixmatchNotifier() : super(MusixmatchState());

  /// Fetch the relevant information retrived from the Musixmatch API
  /// 
  /// Parameters:
  /// - [trackListElement] is the element from the track list
  /// 
  /// Returns:
  /// - A map with the track, artist, album and URL to the lyrics in Musixmatch
  MusixmatchResult _fetchTrackInfo(Map<String, dynamic> trackListElement) {
    final Map<String, dynamic> track = trackListElement["track"];
    final hasLyrics = track["has_lyrics"] == 1 ? true : false;

    // If there are no lyrics available, return a map with a message instead
    // of the URL to the lyrics in Musixmatch
    if (!hasLyrics) {
      return {
        "track" : track["track_name"],
        "artist" : track["artist_name"],
        "album" : track["album_name"],
        "url" : "No lyrics available"
      };
    }

    return {
      "track" : track["track_name"],
      "artist" : track["artist_name"],
      "album" : track["album_name"],
      "url" : track["track_share_url"]
    };
  }

  /// Search for tracks using the Musixmatch API
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
    final List<MusixmatchResult> queryResults = [];
    for (final (result as Map<String, dynamic>) in data["message"]["body"]["track_list"] as List) {
      final musixmatchResult = _fetchTrackInfo(result);
      queryResults.add(musixmatchResult);
    }

    // Update the state with the results from the search
    state.copyWith(qTrack: qTrack, qArtist: qArtist, results: queryResults);
  }
}

/// Musixmatch provider
/// 
/// The initial state is an empty state, with no track, artist or results
final musixmatchProvider = StateNotifierProvider<MusixmatchNotifier, MusixmatchState>(
  (ref) => MusixmatchNotifier()
);
