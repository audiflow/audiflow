import 'package:audiflow/features/browser/common/model/itunes_item.dart';
import 'package:podcast_feed/model/genre.dart';

/// A class that represents an individual Podcast within the search results.
/// Not all properties may contain values for all search providers.
class ITunesSearchItem implements ITunesItem {
  ITunesSearchItem({
    this.artistId,
    required this.collectionId,
    required this.trackId,
    required this.artistName,
    required this.collectionName,
    required this.trackName,
    required this.trackCount,
    required this.collectionCensoredName,
    required this.trackCensoredName,
    this.artistViewUrl,
    required this.collectionViewUrl,
    required this.feedUrl,
    required this.trackViewUrl,
    required this.collectionExplicitness,
    required this.trackExplicitness,
    required this.artworkUrl30,
    required this.artworkUrl60,
    required this.artworkUrl100,
    required this.artworkUrl600,
    required this.releaseDate,
    required this.country,
    required this.primaryGenreName,
    this.contentAdvisoryRating,
    required this.genre,
  });

  factory ITunesSearchItem.fromJson(Map<String, dynamic> json) {
    return ITunesSearchItem(
      collectionId: json['collectionId'] as int,
      artistId: json['artistId'] as int?,
      trackId: json['trackId'] as int,
      artistName: json['artistName'] as String,
      collectionName: json['collectionName'] as String,
      trackName: json['trackName'] as String,
      artistViewUrl: json['artistViewUrl'] as String?,
      collectionCensoredName: json['collectionCensoredName'] as String,
      trackCensoredName: json['trackCensoredName'] as String,
      collectionViewUrl: json['collectionViewUrl'] as String,
      feedUrl: json['feedUrl'] as String,
      trackViewUrl: json['trackViewUrl'] as String,
      artworkUrl30: json['artworkUrl30'] as String,
      artworkUrl60: json['artworkUrl60'] as String,
      artworkUrl100: json['artworkUrl100'] as String,
      artworkUrl600: json['artworkUrl600'] as String,
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      collectionExplicitness: json['collectionExplicitness'] as String,
      trackExplicitness: json['trackExplicitness'] as String,
      trackCount: json['trackCount'] as int,
      country: json['country'] as String,
      primaryGenreName: json['primaryGenreName'] as String,
      contentAdvisoryRating: json['contentAdvisoryRating'] as String?,
      genre: ITunesSearchItem._loadGenres(
        (json['genreIds'] as List<dynamic>).cast<String>(),
        (json['genres'] as List<dynamic>).cast<String>(),
      ),
    );
  }

  static List<Genre> _loadGenres(List<String>? id, List<String>? name) {
    final genres = <Genre>[];

    if (id != null) {
      for (var x = 0; x < id.length; x++) {
        genres.add(Genre(int.parse(id[x]), name![x]));
      }
    }

    return genres;
  }

  /// The iTunes ID of the artist.
  final int? artistId;

  /// The iTunes ID of the collection.
  @override
  final int collectionId;

  /// The iTunes ID of the track.
  final int trackId;

  /// The name of the artist.
  @override
  final String artistName;

  /// The name of the iTunes collection the Podcast is part of.
  @override
  final String collectionName;

  /// The track name.
  @override
  final String trackName;

  /// The censored version of the collection name.
  final String collectionCensoredName;

  /// The censored version of the track name,
  final String trackCensoredName;

  /// The URL of the iTunes page for the artist.
  final String? artistViewUrl;

  /// The URL of the iTunes page for the podcast.
  final String collectionViewUrl;

  /// The URL of the RSS feed for the podcast.
  final String feedUrl;

  /// The URL of the iTunes page for the track.
  final String trackViewUrl;

  /// Podcast artwork URL 30x30.
  final String artworkUrl30;

  /// Podcast artwork URL 60x60.
  final String artworkUrl60;

  /// Podcast artwork URL 100x100.
  final String artworkUrl100;

  /// Podcast artwork URL 600x600.
  final String artworkUrl600;

  /// Podcast release date
  final DateTime releaseDate;

  /// Explicitness of the collection. For example notExplicit.
  final String collectionExplicitness;

  /// Explicitness of the track. For example notExplicit.
  final String trackExplicitness;

  /// Number of tracks in the results.
  final int trackCount;

  /// Country of origin.
  final String country;

  /// Primary genre for the podcast.
  final String primaryGenreName;

  final String? contentAdvisoryRating;

  /// Full list of genres for the podcast.
  final List<Genre> genre;

  /// Contains a URL for the highest resolution artwork available. If no artwork
  /// is available this will return an empty string.
  String get bestArtworkUrl {
    return artworkUrl600;
  }

  /// Contains a URL for the thumbnail resolution artwork. If no thumbnail size
  /// artwork is available this could return a URL for the full size image.
  /// If no artwork is available this will return an empty string.
  @override
  String get thumbnailArtworkUrl {
    return artworkUrl600;
  }
}
