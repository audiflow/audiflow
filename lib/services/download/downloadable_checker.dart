// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/connectivity/connectivity.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/app/navigation_helper.dart';
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

    assert(NavigationHelper.context.mounted);
    if (!NavigationHelper.context.mounted) {
      return false;
    }

    final l10n = L10n.of(NavigationHelper.context)!;
    return await warnNoWifi(
          caption: l10n.captionDownloadNoWifi,
          proceedCaption: l10n.proceedDownload,
        ) ??
        false;
  }
}
