import '../models/episode_number_extractor.dart';
import '../models/season_pattern.dart';
import '../models/season_title_extractor.dart';

/// Pre-configured SeasonPattern for COTEN RADIO podcast.
///
/// Handles:
/// - Regular seasons: `【COTEN RADIO リンカン編15】` -> season title "リンカン編"
/// - 番外編 (extras): `【番外編＃135】` -> season title "番外編"
const SeasonPattern cotenRadioPattern = SeasonPattern(
  id: 'coten_radio',
  feedUrlPatterns: [r'https://anchor\.fm/s/8c2088c/podcast/rss'],
  resolverType: 'rss',
  config: {'groupNullSeasonAs': 0},
  titleExtractor: SeasonTitleExtractor(
    source: 'title',
    pattern: r'【COTEN RADIO (ショート)?\s*(.+?)\s*\d+】',
    group: 2,
    fallbackValue: '番外編',
  ),
  episodeNumberExtractor: EpisodeNumberExtractor(
    pattern: r'(\d+)】',
    captureGroup: 1,
    fallbackToRss: true,
  ),
);
