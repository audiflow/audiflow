import '../models/episode_number_extractor.dart';
import '../models/season_episode_extractor.dart';
import '../models/season_pattern.dart';
import '../models/season_sort.dart';
import '../models/season_title_extractor.dart';

/// Pre-configured SeasonPattern for COTEN RADIO podcast.
///
/// Handles:
/// - Regular seasons: `【COTEN RADIO リンカン編15】` -> season title "リンカン編"
/// - 番外編 (extras): `【番外編＃135】` -> season title "番外編"
/// Custom sort for COTEN RADIO:
/// - Both seasons > 0: compare by season number
/// - Either is 0 (番外編): compare by newest episode date (earlier first in asc)
const _cotenRadioSort = CompositeSeasonSort([
  // Rule 1: If both seasons > 0, sort by season number
  SeasonSortRule(
    field: SeasonSortField.seasonNumber,
    order: SortOrder.ascending,
    condition: SortKeyGreaterThan(0),
  ),
  // Rule 2: Fallback to newest episode date for season 0
  SeasonSortRule(
    field: SeasonSortField.newestEpisodeDate,
    order: SortOrder.ascending,
  ),
]);

const SeasonPattern cotenRadioPattern = SeasonPattern(
  id: 'coten_radio',
  // More flexible URL matching - anchor.fm may redirect or have variations
  feedUrlPatterns: [
    r'https://anchor\.fm/s/8c2088c/podcast/rss',
    r'https://.*anchor\.fm.*8c2088c.*',
  ],
  resolverType: 'rss',
  config: {'groupNullSeasonAs': 0},
  customSort: _cotenRadioSort,
  titleExtractor: SeasonTitleExtractor(
    source: 'title',
    // Pattern handles (drops trailing 編 for regular seasons):
    // - Regular: 【COTEN RADIO リンカン編15】 -> リンカン
    // - Short: 【COTEN RADIOショート ニコラ・テスラ編8】 -> ニコラ・テスラ
    // - Part format: 【COTEN RADIOショート 紫式部 前編】 -> 紫式部
    // - Missing opening bracket: 〜COTEN RADIO 宗教改革編2】 -> 宗教改革
    pattern: r'【?COTEN RADIO(ショート)?\s+(.+?)編?\s*(\d+|前編|中編|後編)】',
    group: 2,
    fallbackValue: '番外編',
    // Fallback handles 番外編 episodes with incorrectly set RSS seasonNumber
    fallback: SeasonTitleExtractor(
      source: 'title',
      pattern: r'【番外編',
      group: 0,
      template: '番外編',
    ),
  ),
  episodeNumberExtractor: EpisodeNumberExtractor(
    pattern: r'(\d+)】',
    captureGroup: 1,
    fallbackToRss: true,
  ),
  seasonEpisodeExtractor: SeasonEpisodeExtractor(
    source: 'title',
    // Primary: 【62-15】 -> season=62, episode=15
    pattern: r'【(\d+)-(\d+)】',
    seasonGroup: 1,
    episodeGroup: 2,
    // Fallback: 【番外編＃135】 or 【番外編#100】 -> season=0, episode=135/100
    fallbackSeasonNumber: 0,
    fallbackEpisodePattern: r'【番外編[＃#](\d+)】',
    fallbackEpisodeCaptureGroup: 1,
  ),
);
