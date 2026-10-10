/// A show subscribed for the store screenshots, identified by its feed.
class ScreenshotShow {
  const ScreenshotShow({required this.feedUrl});

  final String feedUrl;
}

/// What one locale's screenshots show.
class ScreenshotScenario {
  const ScreenshotScenario({
    required this.primary,
    required this.themed,
    required this.themedPlaylistName,
    required this.chaptered,
    required this.extra,
    required this.searchTerm,
    required this.searchCountry,
    required this.stationName,
    required this.stationEpisodesPerShow,
  });

  /// Has a grouped preset: Shows, Series and Curated captions.
  final ScreenshotShow primary;

  /// Has a preset grouped by theme: Smart Playlists caption.
  final ScreenshotShow themed;

  /// Series-tab playlist to show for [themed]; null keeps the first one.
  final String? themedPlaylistName;

  /// Has chapters: played for the Player caption.
  final ScreenshotShow chaptered;

  /// Rounds out the library, queue and station.
  final ScreenshotShow? extra;

  final String searchTerm;

  /// iTunes store country for search, so results match the locale rather
  /// than the simulator's region.
  final String searchCountry;

  final String stationName;

  /// Episodes the station takes from each show; one per show unless the
  /// scenario has too few shows to fill the screen.
  final int stationEpisodesPerShow;

  List<ScreenshotShow> get all => {primary, themed, chaptered, ?extra}.toList();
}

const _cotenRadio = ScreenshotShow(
  feedUrl: 'https://anchor.fm/s/8c2088c/podcast/rss',
);

const _japanese = ScreenshotScenario(
  // Preset: regular / short / extras playlists.
  primary: _cotenRadio,
  // Preset: by_category playlist.
  themed: ScreenshotShow(feedUrl: 'https://anchor.fm/s/81fb5eec/podcast/rss'),
  themedPlaylistName: null,
  // Chapters and transcripts.
  chaptered: ScreenshotShow(
    feedUrl: 'https://rss.listen.style/p/scientalk/rss',
  ),
  extra: null,
  searchTerm: '歴史',
  searchCountry: 'jp',
  stationName: '通勤ミックス',
  stationEpisodesPerShow: 1,
);

const _businessWars = ScreenshotShow(
  feedUrl: 'https://rss.art19.com/business-wars',
);

const _english = ScreenshotScenario(
  // Preset: seasons playlist.
  primary: _businessWars,
  // Preset.
  themed: ScreenshotShow(
    feedUrl: 'https://rss.pdrl.fm/5858fc/feeds.megaphone.fm/thisishistory',
  ),
  // The first playlist, The Tudors, has a single series.
  themedPlaylistName: 'A Dynasty to Die For',
  // Chapters.
  chaptered: ScreenshotShow(feedUrl: 'https://feeds.transistor.fm/acquired'),
  // Transcripts.
  extra: ScreenshotShow(
    feedUrl:
        'https://www.omnycontent.com/d/playlist/'
        'e73c998e-6e60-432f-8610-ae210140c5b1/'
        'd9566f78-0464-4367-9dcc-b05700aeec6f/'
        '7f880b3c-7f67-4b4b-b520-b05700af9172/podcast.rss',
  ),
  searchTerm: 'history',
  searchCountry: 'us',
  stationName: 'Commute Mix',
  stationEpisodesPerShow: 1,
);

/// Returns the scenario for [locale] (`ja` or `en`).
ScreenshotScenario scenarioForLocale(String locale) => switch (locale) {
  'ja' => _japanese,
  'en' => _english,
  _ => throw ArgumentError.value(locale, 'locale', 'expected ja or en'),
};
