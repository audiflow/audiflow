import 'package:audiflow/localization/generated/l10n.dart';

enum EpisodeFilterMode {
  none,
  unplayed,
  completed,
  downloaded;
}

extension EpisodeFilterModeExt on EpisodeFilterMode {
  String labelOf(L10n l10n) {
    switch (this) {
      case EpisodeFilterMode.none:
        return l10n.viewModeEpisodes;
      case EpisodeFilterMode.unplayed:
        return l10n.viewModeUnplayed;
      case EpisodeFilterMode.completed:
        return l10n.viewModePlayed;
      case EpisodeFilterMode.downloaded:
        return l10n.viewModeDownloaded;
    }
  }
}
