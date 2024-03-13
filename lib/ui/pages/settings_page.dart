// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/providers/podcast/podcast_search_provider.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSearchProvider);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              const _AppBar(),
              if (state.isLoading)
                const FillRemainingLoading()
              else if (state.hasError || (state.valueOrNull?.notFound == true))
                FillRemainingError.podcastNoResults()
              else
                _Contents()
            ],
          ),
          const ErrorNotifier(),
        ],
      ),
    );
  }
}

class _AppBar extends HookConsumerWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SliverAppBar(
      pinned: true,
      elevation: 0,
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
            _Section(l10n.settingsStreamingPlayback),
            _Description(l10n.settingsStreamingPlaybackDescription),
            _BinarySwitch(
              l10n.settingsWarnWifi,
              value: state.streamWarnMobileData,
              onToggle: () {
                settings.streamWarnMobileData = !state.streamWarnMobileData;
              },
            ),
            const _Divider(),
            _Section(l10n.settingsManualDownload),
            _Description(l10n.settingsManualDownloadDescription),
            _BinarySwitch(
              l10n.settingsWarnWifi,
              value: state.downloadWarnMobileData,
              onToggle: () {
                settings.downloadWarnMobileData = !state.downloadWarnMobileData;
              },
            ),
            const _Divider(),
            _Section(l10n.settingsAutoDownload),
            _Description(l10n.settingsAutoDownloadDescription),
            _BinarySwitch(
              l10n.settingsWifiOnly,
              value: state.autoDownloadOnlyOnWifi,
              onToggle: () {
                settings.autoDownloadOnlyOnWifi = !state.autoDownloadOnlyOnWifi;
              },
            ),
            _Section(l10n.settingsAutoDelete),
            _Description(l10n.settingsAutoDeleteDescription),
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Divider(
        height: 20,
        thickness: 0.3,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.labelLarge!
          .copyWith(color: theme.colorScheme.primary),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall!
          .copyWith(color: theme.hintColor, fontStyle: FontStyle.italic),
    );
  }
}

class _BinarySwitch extends StatelessWidget {
  const _BinarySwitch(
    this.text, {
    required this.value,
    required this.onToggle,
  });

  final String text;
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          text,
          style: theme.textTheme.bodyMedium!
              .copyWith(color: theme.colorScheme.onSurface),
        ),
        const Spacer(),
        Switch(
          value: value,
          activeTrackColor: theme.colorScheme.tertiary,
          onChanged: (_) => onToggle(),
        ),
      ],
    );
  }
}
