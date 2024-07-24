import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/services/connectivity/connectivity.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:audiflow/ui/dialogs/warn_no_wifi.dart';
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

    final settings = _ref.read(settingsServiceProvider);
    if (!settings.downloadWarnMobileData) {
      return true;
    }

    final router = _ref.read(routerProvider);
    assert(router.context.mounted);
    if (!router.context.mounted) {
      return false;
    }

    final l10n = L10n.of(router.context);
    return await warnNoWifi(
          router.context,
          caption: l10n.captionDownloadNoWifi,
          proceedCaption: l10n.proceedDownload,
        ) ??
        false;
  }
}
