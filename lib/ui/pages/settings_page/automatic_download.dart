// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../settings_page.dart';

class SettingsAutomaticDownloadPage extends HookConsumerWidget {
  const SettingsAutomaticDownloadPage({
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
              _AppBar(l10n.settingsAutoDownload),
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

class _AutoDownloadContents extends ConsumerWidget {
  const _AutoDownloadContents();

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
              title: l10n.settingsAutoDownload,
              description: l10n.settingsAutoDownloadDescription,
            ),
            _BinarySwitch(
              l10n.wifi,
              value: state.autoDownloadOnlyOnWifi,
              onToggle: () {
                settings.autoDownloadOnlyOnWifi = !state.autoDownloadOnlyOnWifi;
              },
            ),
            _BinarySwitch(
              l10n.settingsAutoDownloadRecent,
              value: state.autoDownloadOnlyOnWifi,
              onToggle: () {
                settings.autoDownloadOnlyOnWifi = !state.autoDownloadOnlyOnWifi;
              },
            ),
            const _Divider(),
            _Section(
              title: l10n.settingsAutoDelete,
              description: l10n.settingsAutoDeleteDescription,
            ),
            _BinarySwitch(
              l10n.settingsAutoDeleteAfter,
              value: state.autoDeleteEpisodes,
              onToggle: () {
                settings.autoDeleteEpisodes = !state.autoDeleteEpisodes;
              },
            ),
          ],
        ),
      ),
    );
  }
}
