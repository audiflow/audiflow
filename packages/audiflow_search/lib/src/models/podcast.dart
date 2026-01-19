import 'package:audiflow_search/audiflow_search.dart'
    show PodcastSearchEntityBuilder, StatusCode;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../exceptions/search_exception.dart';

part 'podcast.freezed.dart';

/// Represents a podcast with metadata from podcast directory services.
///
/// This immutable model contains core podcast information returned by
/// podcast search APIs like iTunes Search API.
///
/// Equality is based solely on the [id] field, as the iTunes collection/track
/// ID uniquely identifies a podcast across the platform.
@freezed
abstract class Podcast with _$Podcast {
  const factory Podcast({
    /// Unique identifier for this podcast (iTunes collection ID or track ID).
    required String id,

    /// The name of the podcast.
    required String name,

    /// The name of the podcast creator or host.
    required String artistName,

    /// List of genre names this podcast belongs to.
    @Default(<String>[]) List<String> genres,

    /// Whether this podcast contains explicit content.
    @Default(false) bool explicit,

    /// The RSS feed URL for this podcast.
    String? feedUrl,

    /// A text description of the podcast.
    String? description,

    /// URL to the podcast artwork image.
    String? artworkUrl,

    /// The release date of the most recent episode.
    DateTime? releaseDate,

    /// The total number of episodes/tracks in this podcast.
    int? trackCount,
  }) = _Podcast;
  const Podcast._();

  /// Creates a validated [Podcast] instance.
  ///
  /// Throws [SearchException] with [StatusCode.invalidArgument] if validation fails.
  factory Podcast.validated({
    required String id,
    required String name,
    required String artistName,
    List<String> genres = const <String>[],
    bool explicit = false,
    String? feedUrl,
    String? description,
    String? artworkUrl,
    DateTime? releaseDate,
    int? trackCount,
  }) {
    if (id.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'podcast_model',
        message: 'id must not be empty',
        details: {'field': 'id', 'value': id},
      );
    }
    if (name.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'podcast_model',
        message: 'name must not be empty',
        details: {'field': 'name', 'value': name},
      );
    }
    if (artistName.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'podcast_model',
        message: 'artistName must not be empty',
        details: {'field': 'artistName', 'value': artistName},
      );
    }

    return Podcast(
      id: id,
      name: name,
      artistName: artistName,
      genres: genres,
      explicit: explicit,
      feedUrl: feedUrl,
      description: description,
      artworkUrl: artworkUrl,
      releaseDate: releaseDate,
      trackCount: trackCount,
    );
  }

  /// Creates a [Podcast] instance from iTunes Search API JSON response.
  ///
  /// Parses JSON from iTunes Search API, handling both search and lookup
  /// response formats:
  /// - Uses `collectionId` as primary ID, falls back to `trackId`
  /// - Uses `collectionName` as primary name, falls back to `trackName`
  /// - Selects highest resolution artwork (600 > 100 > 60 > 30)
  /// - Maps `trackExplicitness` values ("explicit" = true, others = false)
  /// - Parses ISO 8601 date strings for `releaseDate`
  ///
  /// Throws [SearchException] with [StatusCode.invalidArgument] if required
  /// fields are missing or invalid.
  factory Podcast.fromJson(Map<String, dynamic> json) {
    final id = json['collectionId']?.toString() ?? json['trackId']?.toString();
    if (id == null || id.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'podcast_model',
        message:
            'Either collectionId or trackId must be present and non-empty in JSON',
        details: {'json': json},
      );
    }

    final name =
        json['collectionName'] as String? ?? json['trackName'] as String?;
    if (name == null || name.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'podcast_model',
        message:
            'Either collectionName or trackName must be present and non-empty in JSON',
        details: {'json': json},
      );
    }

    final artistName = json['artistName'] as String?;
    if (artistName == null || artistName.isEmpty) {
      throw SearchException.invalidArgument(
        providerId: 'podcast_model',
        message: 'artistName must be present and non-empty in JSON',
        details: {'json': json},
      );
    }

    final artworkUrl =
        json['artworkUrl600'] as String? ??
        json['artworkUrl100'] as String? ??
        json['artworkUrl60'] as String? ??
        json['artworkUrl30'] as String?;

    final trackExplicitness = json['trackExplicitness'] as String?;
    final explicit = trackExplicitness == 'explicit';

    final releaseDateStr = json['releaseDate'] as String?;
    final releaseDate = releaseDateStr != null
        ? DateTime.tryParse(releaseDateStr)
        : null;

    final genresList = json['genres'] as List<dynamic>?;
    final genres = genresList?.map((e) => e.toString()).toList() ?? <String>[];

    return Podcast(
      id: id,
      name: name,
      artistName: artistName,
      feedUrl: json['feedUrl'] as String?,
      description: json['description'] as String?,
      genres: genres,
      artworkUrl: artworkUrl,
      releaseDate: releaseDate,
      explicit: explicit,
      trackCount: json['trackCount'] as int?,
    );
  }

  /// Converts this podcast to a raw data map for builder interface.
  ///
  /// This map can be passed to [PodcastSearchEntityBuilder.buildPodcast]
  /// for zero-copy entity construction.
  Map<String, dynamic> toBuilderData() {
    return {
      'id': id,
      'name': name,
      'artistName': artistName,
      'genres': genres,
      'explicit': explicit,
      'feedUrl': feedUrl,
      'description': description,
      'artworkUrl': artworkUrl,
      'releaseDate': releaseDate,
      'trackCount': trackCount,
    };
  }

  /// Two podcasts are equal if they have the same [id].
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Podcast && other.id == id;
  }

  /// Hash code is based on the podcast [id].
  @override
  int get hashCode => id.hashCode;
}
