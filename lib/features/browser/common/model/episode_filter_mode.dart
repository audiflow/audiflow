import 'package:audiflow/localization/generated/l10n.dart';

enum EpisodeFilterMode {
  all,
  unplayed,
  completed,
  downloaded;
}

extension EpisodeFilterModeExt on EpisodeFilterMode {
  String labelOf(L10n l10n) {
    switch (this) {
      case EpisodeFilterMode.all:
        return l10n.episodeFilterModeAll;
      case EpisodeFilterMode.unplayed:
        return l10n.episodeFilterModeUnplayed;
      case EpisodeFilterMode.completed:
        return l10n.episodeFilterModePlayed;
      case EpisodeFilterMode.downloaded:
        return l10n.episodeFilterModeDownloaded;
    }
  }
}
