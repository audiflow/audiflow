// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// https://itunes.apple.com/us/rss/toppodcasts/limit=10/explicit=false/json

import 'package:collection/collection.dart';
import 'package:podcast_feed/model/genre.dart';

class ITunesChartItem {
  ITunesChartItem({
    required this.collectionId,
    required this.artistName,
    required this.collectionName,
    required this.trackName,
    required this.collectionViewUrl,
    required this.trackViewUrl,
    required this.artworkUrl30,
    required this.artworkUrl60,
    required this.artworkUrl100,
    required this.releaseDate,
    required this.genre,
    required this.summary,
  });

  factory ITunesChartItem.fromResponse({
    required Map<String, dynamic> json,
  }) {
    final images = <(int, String)>[];
    if (json.containsKey('im:image')) {
      for (final e in json['im:image'] as List<dynamic>) {
        final url = _getStringEntry(e as Map<String, dynamic>, ['label']);
        final size = _getIntEntry(e, ['attributes', 'height']);
        if (url != null && size != null) {
          images.add((size, url));
        }
      }
    }
    images.sort((a, b) => b.$1 - a.$1);

    return ITunesChartItem(
      collectionId: _getIntEntry(json, ['id', 'attributes', 'im:id'])!,
      artistName: _getStringEntry(json, ['im:artist', 'label'])!,
      collectionName: _getStringEntry(json, ['im:name', 'label'])!,
      trackName: _getStringEntry(json, ['title', 'label'])!,
      collectionViewUrl: _getStringEntry(json, ['link', 'attributes', 'href'])!,
      trackViewUrl: _getStringEntry(json, ['link', 'attributes', 'href'])!,
      artworkUrl30: images.lastWhereOrNull((e) => 30 <= e.$1)!.$2,
      artworkUrl60: images.lastWhereOrNull((e) => 60 <= e.$1)!.$2,
      artworkUrl100: images.lastWhereOrNull((e) => 100 <= e.$1)!.$2,
      genre: ITunesChartItem._loadGenres([
        _getStringEntry(json, ['category', 'attributes', 'im:id'])!,
      ], [
        _getStringEntry(json, ['category', 'attributes', 'label'])!,
      ]),
      releaseDate:
          DateTime.parse(_getStringEntry(json, ['im:releaseDate', 'label'])!),
      // country: json['country'] as String?,
      // primaryGenreName: json['primaryGenreName'] as String?,
      // contentAdvisoryRating: json['contentAdvisoryRating'] as String?,
      summary: _getStringEntry(json, ['summary', 'label'])!,
    );
  }

  /// The iTunes ID of the collection.
  final int collectionId;

  /// The name of the artist.
  final String artistName;

  /// The name of the iTunes collection the Podcast is part of.
  final String collectionName;

  /// The track name.
  final String trackName;

  /// The URL of the iTunes page for the podcast.
  final String collectionViewUrl;

  /// The URL of the iTunes page for the track.
  final String trackViewUrl;

  /// Podcast artwork URL 30x30.
  final String artworkUrl30;

  /// Podcast artwork URL 60x60.
  final String artworkUrl60;

  /// Podcast artwork URL 100x100.
  final String artworkUrl100;

  /// Podcast release date
  final DateTime releaseDate;

  /// Full list of genres for the podcast.
  final List<Genre> genre;

  /// Summary of the podcast.
  final String summary;

  static List<Genre> _loadGenres(List<String>? id, List<String>? name) {
    final genres = <Genre>[];

    if (id != null) {
      for (var x = 0; x < id.length; x++) {
        genres.add(Genre(int.parse(id[x]), name![x]));
      }
    }

    return genres;
  }

  String get thumbnailArtworkUrl => artworkUrl60;

  ITunesChartItem copyWith({
    String? feedUrl,
    String? summary,
  }) {
    return ITunesChartItem(
      collectionId: collectionId,
      artistName: artistName,
      collectionName: collectionName,
      trackName: trackName,
      collectionViewUrl: collectionViewUrl,
      trackViewUrl: trackViewUrl,
      artworkUrl30: artworkUrl30,
      artworkUrl60: artworkUrl60,
      artworkUrl100: artworkUrl100,
      releaseDate: releaseDate,
      genre: genre,
      summary: summary ?? this.summary,
    );
  }

  @override
  String toString() {
    return 'ITunesChartItem{'
        'collectionId: $collectionId, '
        'collectionName: "$collectionName", '
        'trackName: "$trackName", '
        'artistName: "$artistName"}';
  }
}

String? _getStringEntry(Map<String, dynamic> json, List<String> keys) {
  if (json.containsKey(keys[0])) {
    return keys.length == 1
        ? json[keys[0]] as String?
        : _getStringEntry(
            json[keys[0]] as Map<String, dynamic>,
            keys.sublist(1),
          );
  }
  return null;
}

int? _getIntEntry(Map<String, dynamic> json, List<String> keys) {
  if (json.containsKey(keys[0])) {
    return keys.length == 1
        ? int.tryParse(json[keys[0]] as String)
        : _getIntEntry(json[keys[0]] as Map<String, dynamic>, keys.sublist(1));
  }
  return null;
}
