// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/services/podcast/opml_service_provider.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/providers/podcast_search_provider.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

part 'settings_page/automatic_download.dart';
part 'settings_page/parts.dart';
part 'settings_page/text.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSearchProvider);
    final l10n = L10n.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              _AppBar(l10n.settings),
              state.isLoading
                  ? const FillRemainingLoading()
                  : const _Contents(),
            ],
          ),
          const ErrorNotifier(),
        ],
      ),
    );
  }
}

class _Contents extends ConsumerWidget {
  const _Contents();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context)!;
    final state = ref.watch(settingsServiceProvider);
    final settings = ref.watch(settingsServiceProvider.notifier);
    return SliverPadding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 8),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            _Section(
              title: l10n.settingsOnDemandDownloadOnPlayback,
              description: l10n.settingsOnDemandDownloadOnPlaybackDescription,
            ),
            _BinarySwitch(
              l10n.settingsWarnMobileData,
              hint: l10n.settingsWarnMobileDataDescription,
              value: state.streamWarnMobileData,
              onToggle: () {
                settings.streamWarnMobileData = !state.streamWarnMobileData;
              },
            ),
            const _Divider(),
            _Section(
              title: l10n.settingsManualDownload,
              description: l10n.settingsManualDownloadDescription,
            ),
            _BinarySwitch(
              l10n.settingsWarnMobileData,
              value: state.downloadWarnMobileData,
              onToggle: () {
                settings.downloadWarnMobileData = !state.downloadWarnMobileData;
              },
            ),
            const _Divider(),
            _Section(
              title: l10n.settingsOpml,
              description: l10n.settingsOpmlDescription,
            ),
            _TextButton(
              l10n.settingsOpmlImport,
              onTap: () async {
                final result = (await FilePicker.platform.pickFiles())!;
                if (result.files.isNotEmpty) {
                  final file = result.files.first;
                  await ref.read(opmlServiceProvider).loadOPMLFile(file.path!);
                }
              },
            ),
            _TextButton(
              l10n.settingsOpmlExport,
              onTap: () async {
                await ref.read(opmlServiceProvider).saveOPMLFile();
              },
            ),
            // const _Divider(),
            // _Section(
            //   title: l10n.settingsAutoDownload,
            //   description: l10n.settingsAutoDownloadDescription,
            // ),
            // _BinarySwitch(
            //   l10n.wifi,
            //   value: state.autoDownloadOnlyOnWifi,
            //   onToggle: () {
            //     settings.autoDownloadOnlyOnWifi = !state.autoDownloadOnlyOnWifi;
            //   },
            // ),
            // _BinarySwitch(
            //   l10n.settingsAutoDownloadRecent,
            //   value: state.autoDownloadOnlyOnWifi,
            //   onToggle: () {
            //     settings.autoDownloadOnlyOnWifi = !state.autoDownloadOnlyOnWifi;
            //   },
            // ),
            // const _Divider(),
            // _Section(
            //   title: l10n.settingsAutoDelete,
            //   description: l10n.settingsAutoDeleteDescription,
            // ),
            // _BinarySwitch(
            //   l10n.settingsAutoDeleteAfter,
            //   value: state.autoDeleteEpisodes,
            //   onToggle: () {
            //     settings.autoDeleteEpisodes = !state.autoDeleteEpisodes;
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
