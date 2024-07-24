enum SearchProvider {
  itunes,
  podcastIndex;

  String get label {
    switch (this) {
      case SearchProvider.itunes:
        return 'iTunes';
      case SearchProvider.podcastIndex:
        return 'Podcast Index';
    }
  }
}
