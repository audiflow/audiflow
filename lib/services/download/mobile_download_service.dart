// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:audiflow/core/utils.dart';
import 'package:audiflow/entities/app_settings.dart';
import 'package:audiflow/entities/downloadable.dart';
import 'package:audiflow/entities/episode.dart';
import 'package:audiflow/entities/transcript.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/download/download_manager_provider.dart';
import 'package:audiflow/services/download/download_service.dart';
import 'package:audiflow/services/download/downloadable_checker.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mp3_info/mp3_info.dart';
import 'package:rxdart/rxdart.dart';

/// An implementation of a [DownloadService] that handles downloading
/// of episodes on mobile.
class MobileDownloadService extends DownloadService {
  MobileDownloadService(this._ref) {
    _downloadManager.downloadProgress.pipe(downloadProgress);
    downloadProgress.listen(_updateDownloadProgress);
  }

  final Ref _ref;

  Repository get _repository => _ref.watch(repositoryProvider);

  DownloadManager get _downloadManager => _ref.watch(downloadManagerProvider);

  PodcastService get _podcastService => _ref.watch(podcastServiceProvider);

  AppSettings get _appSettings => _ref.watch(settingsServiceProvider);

  BehaviorSubject<DownloadProgress> downloadProgress =
      BehaviorSubject<DownloadProgress>();

  final _log = Logger('MobileDownloadService');

  @override
  void dispose() {
    _downloadManager.dispose();
  }

  @override
  Future<void> deleteDownload(Episode episode) async {
    final download = await _repository.findDownload(episode.guid);
    if (download != null) {
      await _repository.deleteDownload(download);
    }
  }

  @override
  Future<bool> downloadEpisodes(Iterable<Episode> episodes) async {
    if (episodes.isEmpty) {
      return true;
    }

    if (!await hasStoragePermission(_appSettings)) {
      return false;
    }

    final downloadableChecker = _ref.read(downloadableCheckerProvider);
    if (!await downloadableChecker.canDownload(episodes.first)) {
      return false;
    }

    for (final episode in episodes) {
      if (!await _downloadEpisode(episode)) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<bool> downloadEpisode(Episode episode) async {
    if (!await hasStoragePermission(_appSettings)) {
      return false;
    }

    final downloadableChecker = _ref.read(downloadableCheckerProvider);
    if (!await downloadableChecker.canDownload(episode)) {
      return false;
    }
    return _downloadEpisode(episode);
  }

  Future<bool> _downloadEpisode(Episode episode) async {
    try {
      var newEpisode = episode;

      // If this episode contains chapter, fetch them first.
      if (episode.hasChapters) {
        final chapters =
            await _podcastService.loadChaptersByUrl(episode.chaptersUrl!);

        newEpisode = newEpisode.copyWith(chapters: chapters);
      }

      // Next, if the episode supports transcripts download that next
      if (episode.hasTranscripts) {
        var sub = episode.transcriptUrls.firstWhereOrNull(
          (element) => element.type == TranscriptFormat.json,
        );

        sub ??= episode.transcriptUrls.firstWhereOrNull(
          (element) => element.type == TranscriptFormat.subrip,
        );

        if (sub != null) {
          final transcript = await _podcastService.loadTranscriptByUrl(
            episode: episode,
            transcriptUrl: sub,
          );
          await _podcastService.saveTranscript(transcript);
        }
      }

      if (episode != newEpisode) {
        await _podcastService.saveEpisode(newEpisode);
      }

      // Ensure the download directory exists
      final directory = await createDownloadDirectory(_appSettings, newEpisode);
      var uri = Uri.parse(newEpisode.contentUrl!);

      // Filename should be last segment of URI.
      var filename = uri.pathSegments
              .lastWhereOrNull((e) => e.toLowerCase().endsWith('.mp3')) ??
          uri.pathSegments
              .lastWhereOrNull((e) => e.toLowerCase().endsWith('.m4a'));

      if (filename == null) {
        // TODO(unknown): Handle unsupported format.
        return false;
      }

      filename = safeFile(filename);

      // The last segment could also be a full URL. Take a second pass.
      if (filename.contains('/')) {
        try {
          uri = Uri.parse(filename);
          filename = uri.pathSegments.last;
        } on FormatException {
          // It wasn't a URL...
        }
      }

      // Some podcasts use the same file name for each episode. If we have a
      // season and/or episode number provided by iTunes we can use that. We
      // will also append the filename with the publication date if
      // available.
      final prefix = [
        if (episode.season != null) episode.season.toString(),
        if (episode.episode != null) episode.episode.toString(),
        if (episode.publicationDate != null)
          '${episode.publicationDate!.millisecondsSinceEpoch ~/ 1000}',
      ].join('-');
      filename = '$prefix$filename';

      _log.fine(
        'Download episode (${episode.title}) $filename to $directory/$filename',
      );

      /// If we get a redirect to an http endpoint the download will fail.
      /// Let's fully resolve the URL before calling download and ensure it
      /// is https.
      final url = await resolveUrl(episode.contentUrl!, forceHttps: true);

      final taskId =
          await _downloadManager.enqueueTask(url, directory, filename);
      if (taskId == null) {
        return false;
      }

      // Update the episode with download data
      final download = Downloadable(
        pguid: episode.pguid,
        guid: episode.guid,
        url: url,
        directory: await directoryToRecord(_appSettings, newEpisode),
        filename: filename,
        taskId: taskId,
        state: DownloadState.downloading,
      );

      await _repository.saveDownload(download);

      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stack) {
      _log.warning('Episode download failed (${episode.title})', e, stack);
      return false;
    }
  }

  @override
  Future<Downloadable?> findDownloadByGuid(String guid) {
    return _repository.findDownload(guid);
  }

  Future<void> _updateDownloadProgress(DownloadProgress progress) async {
    var download = await _repository.findDownloadByTaskId(progress.id);
    if (download == null) {
      return;
    }

    // We might be called during the cleanup routine during startup.
    // Do not bother updating if nothing has changed.
    if (download.percentage == progress.percentage &&
        download.state == progress.status) {
      return;
    }

    download = download.copyWith(
      percentage: progress.percentage,
      state: progress.status,
    );
    await _repository.saveDownload(download);

    if (progress.status == DownloadState.downloaded &&
        await hasStoragePermission(_appSettings)) {
      await _onDownloadComplete(download);
    }
  }

  Future<void> _onDownloadComplete(Downloadable download) async {
    final stats = await _repository.findEpisodeStats(download.guid);
    var updateParam = EpisodeStatsUpdateParam(
      guid: download.guid,
      downloaded: true,
    );

    if (stats?.duration != null) {
      await _repository.updateEpisodeStats(updateParam);
    } else {
      final path = await resolvePath(_appSettings, download);
      final mp3Info = MP3Processor.fromFile(File(path));

      updateParam = updateParam.copyWith(duration: mp3Info.duration);
      final stats = await _repository.updateEpisodeStats(updateParam);

      var episode = await _repository.findEpisode(stats.guid);
      if (episode != null) {
        episode = episode.copyWith(duration: mp3Info.duration);
        await _repository.saveEpisode(episode);
      }
    }
  }
}
