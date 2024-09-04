import 'package:audiflow/features/feed/model/model.dart';
import 'package:collection/collection.dart';

List<Episode> sortedSeasonEpisodesForView(List<Episode> episodes) =>
    0 < (episodes.firstOrNull?.season ?? 0)
        ? episodes.sorted((a, b) => (a.episode ?? 0) - (b.episode ?? 0))
        : episodes.sorted((a, b) => (b.episode ?? 0) - (a.episode ?? 0));
