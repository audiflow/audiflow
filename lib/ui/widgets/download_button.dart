// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/download/download_progress_provider.dart';
import 'package:seasoning/services/download/download_service_provider.dart';

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
    final percent = downloadState.valueOrNull?.percentage ?? 100;

    return InkWell(
      onTap: () => downloads
          ? ref.read(downloadServiceProvider).deleteDownload(episode)
          : ref.read(downloadServiceProvider).downloadEpisode(episode),
      child: CircularPercentIndicator(
        key: ValueKey(downloads),
        radius: 19,
        lineWidth: 1.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        progressColor: Theme.of(context).indicatorColor,
        animation: downloads && !downloaded,
        animateFromLastPercent: true,
        percent: percent / 100,
        center: downloaded
            ? const Icon(Icons.download_done, size: 22)
            : downloads
                ? Text('$percent%', style: const TextStyle(fontSize: 12))
                : const Icon(Icons.download, size: 22),
      ),
    );
  }
}
