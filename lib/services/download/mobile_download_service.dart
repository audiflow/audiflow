// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:logging/logging.dart';
import 'package:mp3_info/mp3_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/transcript.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/services/download/download_manager.dart';
import 'package:seasoning/services/download/download_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';

/// An implementation of a [DownloadService] that handles downloading
/// of episodes on mobile.
class MobileDownloadService extends DownloadService {
  MobileDownloadService({
    required this.repository,
    required this.downloadManager,
    required this.podcastService,
  }) {
    downloadManager.downloadProgress.pipe(downloadProgress);
    downloadProgress.listen(_updateDownloadProgress);
  }

  static BehaviorSubject<DownloadProgress> downloadProgress =
      BehaviorSubject<DownloadProgress>();

  final log = Logger('MobileDownloadService');
  final Repository repository;
  final DownloadManager downloadManager;
  final PodcastService podcastService;

  @override
  void dispose() {
    downloadManager.dispose();
  }

  @override
  Future<bool> downloadEpisode(Episode episode) async {
    try {
      if (!await hasStoragePermission()) {
        return false;
      }

      var newEpisode = episode;

      // If this episode contains chapter, fetch them first.
      if (episode.hasChapters) {
        final chapters =
            await podcastService.loadChaptersByUrl(url: episode.chaptersUrl!);

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
          final transcript = await podcastService.loadTranscriptByUrl(
            episode: episode,
            transcriptUrl: sub,
          );
          await podcastService.saveTranscript(transcript);
        }
      }

      if (episode != newEpisode) {
        await podcastService.saveEpisode(newEpisode);
      }

      // Ensure the download directory exists
      final directory = await createDownloadDirectory(newEpisode);
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

      log.fine(
        'Download episode (${episode.title}) $filename to $directory/$filename',
      );

      /// If we get a redirect to an http endpoint the download will fail.
      /// Let's fully resolve the URL before calling download and ensure it
      /// is https.
      final url = await resolveUrl(episode.contentUrl!, forceHttps: true);

      final taskId =
          await downloadManager.enqueueTask(url, directory, filename);
      if (taskId == null) {
        return false;
      }

      // Update the episode with download data
      final download = Downloadable(
        pguid: episode.pguid,
        guid: episode.guid,
        url: url,
        directory: await directoryToRecord(episode: newEpisode),
        filename: filename,
        taskId: taskId,
        state: DownloadState.downloading,
      );

      await repository.saveDownload(download);

      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stack) {
      log.warning('Episode download failed (${episode.title})', e, stack);
      return false;
    }
  }

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) {
    return repository.findDownloadByTaskId(taskId);
  }

  Future<void> _updateDownloadProgress(DownloadProgress progress) async {
    var download = await repository.findDownloadByTaskId(progress.id);
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
    await repository.saveDownload(download);

    if (progress.percentage == 100 && await hasStoragePermission()) {
      // If we do not have a duration for this file - let's calculate it
      var episode = await repository.findEpisodeByGuid(download.guid);
      if (episode?.duration == 0) {
        final path = await resolvePath(download);
        final mp3Info = MP3Processor.fromFile(File(path));
        episode = episode!.copyWith(duration: mp3Info.duration.inSeconds);
        await repository.saveEpisode(episode);
      }
    }
  }
}
