import '../models/smart_playlist_pattern.dart';

/// Pre-configured SmartPlaylistPattern for NewsConnect podcast.
///
/// Groups episodes into two smart playlists:
/// - Daily News: weekday episodes matching the date pattern
///   (yearGrouped)
/// - Programs: all other titled episodes (flat list)
const SmartPlaylistPattern newsConnectPattern = SmartPlaylistPattern(
  id: 'news_connect',
  feedUrlPatterns: [
    r'https://anchor\.fm/s/81fb5eec/podcast/rss',
    r'https://.*anchor\.fm.*81fb5eec.*',
  ],
  resolverType: 'category',
  yearGroupedEpisodes: true,
  config: {
    'categories': [
      {
        'id': 'daily_news',
        'displayName': '平日版',
        'pattern': r'【\d+月\d+日】',
        'yearGrouped': true,
        'sortKey': 1,
      },
      {
        'id': 'programs',
        'displayName': '特集',
        'pattern': r'【(?!\d+月\d+日)\S+',
        'yearGrouped': false,
        'sortKey': 2,
        'subCategories': [
          {'id': 'saturday', 'displayName': '土曜版', 'pattern': r'【土曜版'},
          {'id': 'news_talk', 'displayName': 'ニュース小話', 'pattern': r'【ニュース小話'},
        ],
      },
    ],
  },
);
