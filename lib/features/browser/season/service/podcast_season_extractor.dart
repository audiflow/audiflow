import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/podcast_season_title_extractor.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/datetime.dart';
import 'package:collection/collection.dart';

export 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/podcast_season_title_extractor.dart'
    show SeasonDistinction;

class PodcastSeasonExtractor {
  PodcastSeasonExtractor(
    this.titleExtractor,
    this.podcast,
    this.knownSeasons,
  );

  /// Extractor for season title.
  final PodcastSeasonTitleExtractor titleExtractor;

  /// The podcast to be processed.
  final Podcast podcast;

  /// The list of seasons already processed earlier.
  final List<Season> knownSeasons;

  /// The list of seasons updated in this session.
  final updatedSeasons = <Season>{};

  /// Process new episodes.
  void process(Iterable<Episode> episodes) {
    if (episodes.isEmpty) {
      return;
    }

    final seasons = <Season>{
      ...updatedSeasons,
      ...knownSeasons.where((k) => !updatedSeasons.any((s) => s.id == k.id)),
    };

    final Iterable<Season> allSeasons;
    switch (titleExtractor.distinction) {
      case SeasonDistinction.seasonNum:
        allSeasons = _extractSeasonsBySeasonNum(
          titleExtractor,
          podcast,
          episodes,
          seasons,
        );
      case SeasonDistinction.title:
        allSeasons = _extractSeasonsWithTitles(
          titleExtractor,
          podcast,
          episodes,
          seasons,
        );
    }

    updatedSeasons
      ..clear()
      ..addAll(allSeasons.where((s) => !knownSeasons.any((k) => s == k)));
  }

  void remove(Iterable<Episode> episodes) {
    if (episodes.isEmpty) {
      return;
    }

    final seasons = [
      ...updatedSeasons,
      ...knownSeasons.where((k) => !updatedSeasons.any((s) => s.id == k.id)),
    ].map(
      (season) {
        if (season.episodeIds.any((id) => episodes.any((e) => e.id == id))) {
          final episodeIds = season.episodeIds
              .where((id) => !episodes.any((e) => e.id == id))
              .toList();
          return season.copyWith(episodeIds: episodeIds);
        } else {
          return season;
        }
      },
    );

    updatedSeasons
      ..clear()
      ..addAll(seasons.where((s) => !knownSeasons.any((k) => s == k)));
  }

  void flush() {
    final seasons = <Season>{
      ...updatedSeasons.where((s) => s.episodeIds.isNotEmpty),
      ...knownSeasons.where((k) => !updatedSeasons.any((s) => s.id == k.id)),
    };

    knownSeasons
      ..clear()
      ..addAll(seasons);
    updatedSeasons.clear();
  }

  /// Compile new episodes into seasons based on Episode.seasonNum.
  ///
  /// It returns only new or updated seasons.
  Iterable<Season> _extractSeasonsBySeasonNum(
    PodcastSeasonTitleExtractor titleExtractor,
    Podcast podcast,
    Iterable<Episode> episodes,
    Iterable<Season> seasons,
  ) {
    // If there are no new episodes, return empty list.
    if (episodes.isEmpty) {
      return [];
    }

    // Transform new episodes -> map<seasonTitle, List<Episode>>
    final map = <int?, List<Episode>>{};
    for (final episode in episodes) {
      if (map.containsKey(episode.season)) {
        map[episode.season]!
          ..removeWhere((e) => e.id == episode.id)
          ..add(episode);
      } else {
        map[episode.season] = [episode];
      }
    }

    // If the podcast seems not to support "season", return empty list.
    if (seasons.isEmpty && (map.keys.length < 2 && map.keys.first == null)) {
      return [];
    }

    // Return only new or updated seasons.
    return map.keys.map((seasonNum) {
      final season = seasons.firstWhereOrNull((s) => s.seasonNum == seasonNum);
      final seasonEpisodes =
          map[seasonNum]!.sorted((a, b) => a.ordinal - b.ordinal);
      return season == null
          ? _createNewSeason(podcast, seasonNum, seasonEpisodes)
          : _updatedSeasonWith(season, seasonEpisodes);
    });
  }

  /// Compile new episodes into seasons based on Episode.title.
  ///
  /// It returns only new or updated seasons.
  Iterable<Season> _extractSeasonsWithTitles(
    PodcastSeasonTitleExtractor titleExtractor,
    Podcast podcast,
    Iterable<Episode> episodes,
    Iterable<Season> seasons,
  ) {
    // If there are no new episodes, return empty list.
    if (episodes.isEmpty) {
      return [];
    }

    // Transform new episodes -> map<seasonTitle, List<Episode>>
    final map = <String?, List<Episode>>{};
    for (final episode in episodes) {
      final seasonTitle = _extractSeasonTitle(episode);
      if (map.containsKey(seasonTitle)) {
        map[seasonTitle]!
          ..removeWhere((e) => e.id == episode.id)
          ..add(episode);
      } else {
        map[seasonTitle] = [episode];
      }
    }

    // If the podcast seems not to support "season", return empty list.
    if (seasons.isEmpty && map.keys.length < 2) {
      return [];
    }

    // Create a list of new or updated seasons.
    final updatedSeasons = map.keys.map((seasonTitle) {
      final season = seasons.firstWhereOrNull((s) => s.title == seasonTitle);
      final seasonEpisodes =
          map[seasonTitle]!.sorted((a, b) => a.ordinal - b.ordinal);
      return season == null
          ? _createNewSeason(podcast, -1, seasonEpisodes)
          : _updatedSeasonWith(season, seasonEpisodes);
    });

    // Return new or updated seasons as remapping season# of the original list.
    return [
      ...map.keys,
      ...seasons.map((s) => s.title),
    ]
        .map(
      // Create a list of all of merged seasons sorted by publication date.
      (seasonTitle) =>
          updatedSeasons.firstWhereOrNull((s) => s.title == seasonTitle) ??
          seasons.firstWhere((s) => s.title == seasonTitle),
    )
        .sorted((a, b) {
      if (a.firstPublicationDate != null && b.firstPublicationDate != null) {
        return a.firstPublicationDate!.millisecondsSinceEpoch
            .compareTo(b.firstPublicationDate!.millisecondsSinceEpoch);
      }
      return a.firstPublicationDate != null
          ? -1
          : b.firstPublicationDate != null
              ? 1
              : (a.title ?? '').compareTo(b.title ?? '');
    }).mapIndexed((i, season) {
      // remap season#.
      final seasonNum = i + 1;
      if (season.seasonNum != seasonNum) {
        // Return rewrote season.
        return season.copyWith(
          guid: calcSeasonGuid(feedUrl: podcast.feedUrl, seasonNum: seasonNum),
          seasonNum: seasonNum,
        );
      } else if (map.containsKey(season.title)) {
        // Return updated season.
        return season;
      } else {
        // Return null if the season is not updated.
        return null;
      }
    }).whereNotNull();
  }

  /// Extract season title from episode title.
  String? _extractSeasonTitle(Episode episode) =>
      titleExtractor.extractSeasonTitle(
        podcastTitle: podcast.title,
        title: episode.title,
        episodeNum: episode.episode,
        seasonNum: episode.season,
      );

  /// Create a new season.
  Season _createNewSeason(
    Podcast podcast,
    int? seasonNum,
    List<Episode> episodes,
  ) {
    final firstPublicationDate = episodes.fold<DateTime?>(null, (prev, e) {
      return prev != null && e.publicationDate != null
          ? minDateTime(prev, e.publicationDate!)
          : prev ?? e.publicationDate;
    });
    final latestPublicationDate = episodes.fold<DateTime?>(null, (prev, e) {
      return prev != null && e.publicationDate != null
          ? maxDateTime(prev, e.publicationDate!)
          : prev ?? e.publicationDate;
    });
    final totalDurationMS = episodes.fold<int>(
      0,
      (total, e) => total + (e.duration?.inMilliseconds ?? 0),
    );
    return Season(
      guid: calcSeasonGuid(feedUrl: podcast.feedUrl, seasonNum: seasonNum),
      pid: episodes.first.pid,
      seasonNum: seasonNum,
      title: _extractSeasonTitle(episodes.first),
      imageUrl: episodes.first.imageUrl,
      episodeIds: episodes.map((v) => v.id).toList(),
      firstPublicationDate: firstPublicationDate,
      latestPublicationDate: latestPublicationDate,
      totalDurationMS: totalDurationMS,
    );
  }

  /// Create a updated version of an existing season.
  Season _updatedSeasonWith(
    Season season,
    List<Episode> episodes,
  ) {
    final firstPublicationDate =
        episodes.fold(season.firstPublicationDate, (prev, e) {
      return prev != null && e.publicationDate != null
          ? minDateTime(prev, e.publicationDate!)
          : prev ?? e.publicationDate;
    });
    final latestPublicationDate =
        episodes.fold(season.latestPublicationDate, (prev, e) {
      return prev != null && e.publicationDate != null
          ? maxDateTime(prev, e.publicationDate!)
          : prev ?? e.publicationDate;
    });
    final totalDurationMS =
        episodes.fold<int>(season.totalDurationMS, (total, e) {
      return total + (e.duration?.inMilliseconds ?? 0);
    });
    return season.copyWith(
      episodeIds: [...season.episodeIds, ...episodes.map((e) => e.id)],
      title: firstPublicationDate != season.firstPublicationDate
          ? _extractSeasonTitle(episodes.first)
          : season.title,
      firstPublicationDate: firstPublicationDate,
      latestPublicationDate: latestPublicationDate,
      totalDurationMS: totalDurationMS,
    );
  }
}
