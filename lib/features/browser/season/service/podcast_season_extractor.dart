import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/service/podcast_season_title_extractor/podcast_season_title_extractor.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:collection/collection.dart';

class PodcastSeasonExtractor {
  PodcastSeasonExtractor(
    this.titleExtractor,
    this.podcast,
    this.knownSeasons,
  );

  final PodcastSeasonTitleExtractor titleExtractor;
  final Podcast podcast;
  final List<Season> knownSeasons;
  final updatedSeasons = <Season>{};

  void process(Iterable<Episode> episodes) {
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
        map[episode.season]!.add(episode);
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
      return season == null
          ? _createNewSeason(podcast, seasonNum, map[seasonNum]!)
          : _updatedSeasonWith(season, map[seasonNum]!);
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
        map[seasonTitle]!.add(episode);
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
      return season == null
          ? _createNewSeason(podcast, -1, map[seasonTitle]!)
          : _updatedSeasonWith(season, map[seasonTitle]!);
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
        return season.copyWith(seasonNum: seasonNum);
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
    final firstPublicationDate = episodes.fold<DateTime?>(null, (latest, e) {
      return e.publicationDate == null
          ? latest
          : latest == null
              ? e.publicationDate
              : latest.isBefore(e.publicationDate!)
                  ? latest
                  : e.publicationDate;
    });
    final latestPublicationDate = episodes.fold<DateTime?>(null, (latest, e) {
      return e.publicationDate == null
          ? latest
          : latest == null
              ? e.publicationDate
              : latest.isBefore(e.publicationDate!)
                  ? e.publicationDate
                  : latest;
    });
    final totalDurationMS = episodes.fold<int>(
      0,
      (total, e) => total + (e.duration?.inMilliseconds ?? 0),
    );
    final firstEpisode = episodes.first;
    return Season(
      guid: calcSeasonGuid(feedUrl: podcast.feedUrl, seasonNum: seasonNum),
      pid: firstEpisode.pid,
      seasonNum: seasonNum,
      title: _extractSeasonTitle(firstEpisode),
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
        episodes.fold(season.firstPublicationDate, (latest, e) {
      return e.publicationDate == null
          ? latest
          : latest == null
              ? e.publicationDate
              : latest.isBefore(e.publicationDate!)
                  ? latest
                  : e.publicationDate;
    });
    final latestPublicationDate =
        episodes.fold(season.latestPublicationDate, (latest, e) {
      return e.publicationDate == null
          ? latest
          : latest == null
              ? e.publicationDate
              : latest.isBefore(e.publicationDate!)
                  ? e.publicationDate
                  : latest;
    });
    final totalDurationMS =
        episodes.fold<int>(season.totalDurationMS, (total, e) {
      return total + (e.duration?.inMilliseconds ?? 0);
    });
    return season.copyWith(
      episodeIds: [...season.episodeIds, ...episodes.map((e) => e.id)],
      firstPublicationDate: firstPublicationDate,
      latestPublicationDate: latestPublicationDate,
      totalDurationMS: totalDurationMS,
    );
  }
}
