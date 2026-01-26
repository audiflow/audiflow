import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/src/features/feed/patterns/coten_radio_pattern.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cotenRadioPattern', () {
    test('matches COTEN RADIO feed URL', () {
      expect(
        cotenRadioPattern.matchesPodcast(
          null,
          'https://anchor.fm/s/8c2088c/podcast/rss',
        ),
        isTrue,
      );
    });

    test('does not match other feed URLs', () {
      expect(
        cotenRadioPattern.matchesPodcast(
          null,
          'https://feeds.example.com/podcast/rss',
        ),
        isFalse,
      );
    });

    test('has correct resolver type', () {
      expect(cotenRadioPattern.resolverType, 'rss');
    });

    test('has groupNullSeasonAs config', () {
      expect(cotenRadioPattern.config['groupNullSeasonAs'], 0);
    });

    test('titleExtractor extracts season name from regular episode', () {
      final episode = SimpleEpisodeData(
        title: '【62-15】何が変わった?【COTEN RADIO リンカン編15】',
        seasonNumber: 62,
      );

      final result = cotenRadioPattern.titleExtractor!.extract(episode);
      expect(result, 'リンカン');
    });

    test('titleExtractor returns 番外編 for null seasonNumber', () {
      final episode = SimpleEpisodeData(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: null,
      );

      final result = cotenRadioPattern.titleExtractor!.extract(episode);
      expect(result, '番外編');
    });

    test('episodeNumberExtractor extracts from regular episode title', () {
      final episode = SimpleEpisodeData(
        title: '【62-15】何が変わった?【COTEN RADIO リンカン編15】',
        seasonNumber: 62,
        episodeNumber: 100,
      );

      final result = cotenRadioPattern.episodeNumberExtractor!.extract(episode);
      expect(result, 15);
    });

    test('episodeNumberExtractor uses RSS episodeNumber for 番外編', () {
      final episode = SimpleEpisodeData(
        title: '【番外編＃135】仏教のこと',
        seasonNumber: null,
        episodeNumber: 135,
      );

      final result = cotenRadioPattern.episodeNumberExtractor!.extract(episode);
      expect(result, 135);
    });

    test('titleExtractor extracts from ショート format (no space)', () {
      // ショート series have "RADIOショート" without space before ショート
      final episode = SimpleEpisodeData(
        title: '【61-1】電撃人生！ニコラ・テスラ【COTEN RADIOショート ニコラ・テスラ編1】',
        seasonNumber: 61,
      );

      final result = cotenRadioPattern.titleExtractor!.extract(episode);
      expect(result, 'ニコラ・テスラ');
    });

    test('titleExtractor handles 前編/後編 format', () {
      final episode = SimpleEpisodeData(
        title: '【49-1】いとをかし！源氏物語【COTEN RADIOショート 紫式部 前編】',
        seasonNumber: 49,
      );

      final result = cotenRadioPattern.titleExtractor!.extract(episode);
      expect(result, '紫式部');
    });

    test('titleExtractor handles missing opening bracket', () {
      final episode = SimpleEpisodeData(
        title: '【21-2】ローマ教皇至上権〜COTEN RADIO 宗教改革編2】',
        seasonNumber: 21,
      );

      final result = cotenRadioPattern.titleExtractor!.extract(episode);
      expect(result, '宗教改革');
    });

    test(
      'titleExtractor uses fallback for 番外編 with incorrect seasonNumber',
      () {
        // RSS feed incorrectly sets seasonNumber for some 番外編 episodes
        final episode = SimpleEpisodeData(
          title: '【番外編＃117】大切なものを大切に',
          seasonNumber: 117, // Incorrectly set in RSS
        );

        final result = cotenRadioPattern.titleExtractor!.extract(episode);
        expect(result, '番外編');
      },
    );
  });
}
