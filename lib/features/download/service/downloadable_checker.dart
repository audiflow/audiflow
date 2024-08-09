import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/common/ui/warn_no_wifi.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'downloadable_checker.g.dart';

@Riverpod(keepAlive: true)
DownloadableChecker downloadableChecker(DownloadableCheckerRef ref) {
  return DownloadableChecker._(ref);
}

class DownloadableChecker {
  DownloadableChecker._(this._ref);

  final Ref _ref;

  Future<bool> canDownload(Episode episode) async {
    if (!await usesCellularConnection()) {
      return true;
    }

    if (!_ref.read(appPreferenceRepositoryProvider).downloadWarnMobileData) {
      return true;
    }

    final routerContext = _ref.read(routerContextProvider);
    if (!routerContext.mounted) {
      return false;
    }

    final l10n = L10n.of(routerContext);
    return await warnNoWifi(
          routerContext,
          caption: l10n.captionDownloadNoWifi,
          proceedCaption: l10n.proceedDownload,
        ) ??
        false;
  }
}
