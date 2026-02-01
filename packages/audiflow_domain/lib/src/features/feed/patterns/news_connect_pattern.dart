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
    'playlists': [
      {
        'id': 'by_category',
        'displayName': 'カテゴリ別',
        'contentType': 'groups',
        'yearHeaderMode': 'none',
        'episodeYearHeaders': true,
        'groups': [
          {'id': 'daily_news', 'displayName': '平日版', 'pattern': r'【\d+月\d+日】'},
          {'id': 'saturday', 'displayName': '土曜版', 'pattern': r'【土曜版'},
          {'id': 'news_talk', 'displayName': 'ニュース小話', 'pattern': r'【ニュース小話'},
          {'id': 'special', 'displayName': '特別編', 'pattern': r'【.*?特別編.*?】'},
          {'id': 'expat', 'displayName': '越境日本人編', 'pattern': r'【越境日本人編'},
          {'id': 'holiday', 'displayName': '祝日版', 'pattern': r'【祝日版'},
          {'id': 'other', 'displayName': 'その他'},
        ],
      },
      {
        'id': 'by_year',
        'displayName': '年別',
        'contentType': 'groups',
        'yearHeaderMode': 'perEpisode',
        'episodeYearHeaders': false,
        'groups': [
          {'id': 'daily_news', 'displayName': '平日版', 'pattern': r'【\d+月\d+日】'},
          {'id': 'saturday', 'displayName': '土曜版', 'pattern': r'【土曜版'},
          {'id': 'news_talk', 'displayName': 'ニュース小話', 'pattern': r'【ニュース小話'},
          {'id': 'special', 'displayName': '特別編', 'pattern': r'【.*?特別編.*?】'},
          {'id': 'expat', 'displayName': '越境日本人編', 'pattern': r'【越境日本人編'},
          {'id': 'holiday', 'displayName': '祝日版', 'pattern': r'【祝日版'},
          {'id': 'other', 'displayName': 'その他'},
        ],
      },
    ],
  },
);
