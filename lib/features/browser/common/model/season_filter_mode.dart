import 'package:audiflow/localization/generated/l10n.dart';

enum SeasonFilterMode {
  all,
  unplayed,
}

extension SeasonFilterModeExt on SeasonFilterMode {
  String labelOf(L10n l10n) {
    switch (this) {
      case SeasonFilterMode.all:
        return l10n.seasonFilterModeAll;
      case SeasonFilterMode.unplayed:
        return l10n.seasonFilterModeUnplayed;
    }
  }
}
