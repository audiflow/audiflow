abstract class ITunesItem {
  /// The iTunes ID of the collection.
  int get collectionId;

  /// The name of the artist.
  String get artistName;

  /// The name of the iTunes collection the Podcast is part of.
  String get collectionName;

  /// The track name.
  String get trackName;

  String get thumbnailArtworkUrl;
}
