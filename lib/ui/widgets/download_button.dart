// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/download/download_progress_provider.dart';
import 'package:audiflow/services/download/download_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// Displays a download button for an episode.
///
/// Can be passed a percentage representing the download progress which
/// the button will then animate to show progress.
class DownloadButton extends ConsumerWidget {
  const DownloadButton(
    this.episode, {
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(downloadProgressProvider(episode));
    final downloads = downloadState.valueOrNull != null;
    final downloaded = downloads && downloadState.valueOrNull!.downloaded;
    final percent =
        (downloadState.valueOrNull?.percentage ?? 0).toDouble() / 100;
    final downloading = 0 < percent && percent < 1;

    final theme = Theme.of(context);
    final style = OutlinedButton.styleFrom(
      shape: const StadiumBorder(),
      foregroundColor: theme.hintColor,
      minimumSize: const Size(30, 26),
      padding: const EdgeInsets.only(left: 6, right: 6),
      side: BorderSide(color: theme.hintColor),
    );

    return OutlinedButton(
      style: style,
      onPressed: () => downloads
          ? ref.read(downloadServiceProvider).deleteDownload(episode)
          : ref.read(downloadServiceProvider).downloadEpisode(episode),
      child: SizedBox(
        width: 26,
        height: 26,
        child: Stack(
          children: [
            if (downloading)
              Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    key: ValueKey(downloads),
                    value: percent,
                    color: theme.colorScheme.tertiary,
                    // backgroundColor: theme.colorScheme.secondaryContainer,
                  ),
                ),
              ),
            if (!downloading)
              Center(
                child: Icon(
                  downloaded || percent == 1
                      ? Symbols.download_done
                      : Symbols.download,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
