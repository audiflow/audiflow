import 'dart:async';
import 'dart:io';

import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/download/service/download_manager.dart';
import 'package:audiflow/features/download/service/download_path.dart';
import 'package:audiflow/features/download/service/download_service.dart';
import 'package:audiflow/features/download/service/downloadable_checker.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/features/preference/model/app_preference.dart';
import 'package:audiflow/utils/http.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_info/mp3_info.dart';
import 'package:rxdart/rxdart.dart';

/// An implementation of a [DownloadService] that handles downloading
/// of episodes on mobile.
class DefaultDownloadService extends DownloadService {
  DefaultDownloadService(this._ref) {
    _downloadManager.downloadProgress.pipe(downloadProgress);
    downloadProgress.listen(_updateDownloadProgress);
  }

  final Ref _ref;

  EpisodeRepository get _episodeRepository =>
      _ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      _ref.read(episodeStatsRepositoryProvider);

  DownloadRepository get _downloadRepository =>
      _ref.read(downloadRepositoryProvider);

  DownloadManager get _downloadManager => _ref.read(downloadManagerProvider);

  DownloadPath get _downloadPath => _ref.read(downloadPathProvider);

  AppPreference get _appPreference =>
      _ref.read(appPreferenceRepositoryProvider);

  BehaviorSubject<DownloadProgress> downloadProgress =
      BehaviorSubject<DownloadProgress>();

  @override
  void dispose() {
    _downloadManager.dispose();
  }

  @override
  Future<List<Downloadable>> loadAllDownloads() async {
    return _downloadRepository.queryDownloads();
  }

  @override
  Future<void> deleteDownload(Episode episode) async {
    final download = await _downloadRepository.findDownload(episode.id);
    if (download == null) {
      return;
    }

    // If this episode is currently downloading, cancel the download first.
    if (download.state == DownloadState.downloaded) {
      if (_appPreference.markDeletedEpisodesAsPlayed) {
        // episode.played = true;
      }
    } else if (download.state == DownloadState.downloading &&
        download.percentage < 100) {
      await FlutterDownloader.cancel(taskId: download.taskId);
    }

    await _downloadRepository.deleteDownload(download);

    if (await _downloadPath.hasStoragePermission()) {
      final f =
          File.fromUri(Uri.file(await _downloadPath.resolvePath(download)));
      if (f.existsSync()) {
        logger.d('Deleting file ${f.path}');
        await f.delete();
      }
    }
  }

  @override
  Future<void> downloadEpisodes(
    Iterable<Episode> episodes, {
    bool unplayedOnly = false,
  }) async {
    if (!await _downloadPath.hasStoragePermission()) {
      return;
    }

    final ids = episodes.map((e) => e.id);
    final downloads = await _downloadRepository.findDownloads(ids);
    final statsList = unplayedOnly
        ? <EpisodeStats>[]
        : await _episodeStatsRepository.findEpisodeStatsList(ids);

    final toDownload = episodes.where((e) {
      final stats = statsList.firstWhereOrNull((s) => s?.eid == e.id);
      return stats?.played != true;
    }).where((e) {
      final download = downloads.firstWhereOrNull((d) => d?.id == e.id);
      return download?.state != DownloadState.downloaded;
    });
    if (toDownload.isEmpty) {
      return;
    }

    final downloadableChecker = _ref.read(downloadableCheckerProvider);
    if (!await downloadableChecker.canDownload(episodes.first)) {
      return;
    }

    for (final episode in episodes) {
      if (!await _downloadEpisode(episode)) {
        return;
      }
    }
  }

  @override
  Future<bool> downloadEpisode(Episode episode) async {
    if (!await _downloadPath.hasStoragePermission()) {
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
      final newEpisode = episode;

      // If this episode contains chapter, fetch them first.
      // if (episode.hasChapters) {
      //   final chapters =
      //       await _podcastService.loadChaptersByUrl(episode.chaptersUrl!);
      //
      //   newEpisode = newEpisode.copyWith(chapters: chapters);
      // }

      // Next, if the episode supports transcripts download that next
      if (episode.transcripts.isNotEmpty) {
        var sub = episode.transcripts.firstWhereOrNull(
          (element) => element.type == TranscriptFormat.json,
        );

        sub ??= episode.transcripts.firstWhereOrNull(
          (element) => element.type == TranscriptFormat.subrip,
        );

        // if (sub != null) {
        //   final transcript = await _podcastService.loadTranscriptByUrl(
        //     episode: episode,
        //     transcriptUrl: sub,
        //   );
        //   await _podcastService.saveTranscript(transcript);
        // }
      }

      if (episode != newEpisode) {
        await _episodeRepository.saveEpisode(newEpisode);
      }

      // Ensure the download directory exists
      final directory = await _downloadPath.createDownloadDirectory(newEpisode);
      var uri = Uri.parse(newEpisode.contentUrl);

      // Filename should be last segment of URI.
      var filename = uri.pathSegments
              .lastWhereOrNull((e) => e.toLowerCase().endsWith('.mp3')) ??
          uri.pathSegments
              .lastWhereOrNull((e) => e.toLowerCase().endsWith('.m4a'));

      if (filename == null) {
        // TODO(unknown): Handle unsupported format.
        return false;
      }

      filename = _downloadPath.safeFile(filename);

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

      logger.d(
        'Download episode (${episode.title}) $filename to $directory/$filename',
      );

      /// If we get a redirect to an http endpoint the download will fail.
      /// Let's fully resolve the URL before calling download and ensure it
      /// is https.
      final url = await resolveUrl(episode.contentUrl, forceHttps: true);

      final taskId =
          await _downloadManager.enqueueTask(url, directory, filename);
      if (taskId == null) {
        return false;
      }

      // Update the episode with download data
      final download = Downloadable(
        pid: episode.pid,
        eid: episode.id,
        ordinal: episode.ordinal,
        url: url,
        directory: await _downloadPath.directoryToRecord(newEpisode),
        filename: filename,
        taskId: taskId,
        state: DownloadState.downloading,
        downloadStartedAt: DateTime.now(),
      );

      await _downloadRepository.saveDownload(download);

      return true;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      logger.w(() => 'Episode download failed (${episode.title}) $e');
      return false;
    }
  }

  @override
  Future<Downloadable?> findDownload(Episode episode) {
    return _downloadRepository.findDownload(episode.id);
  }

  Future<void> _updateDownloadProgress(DownloadProgress progress) async {
    var download = await _downloadRepository.findDownloadByTaskId(progress.id);
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
    await _downloadRepository.saveDownload(download);

    if (progress.status == DownloadState.downloaded &&
        await _downloadPath.hasStoragePermission()) {
      await _onDownloadComplete(download);
    }
  }

  Future<void> _onDownloadComplete(Downloadable download) async {
    final stats = await _episodeStatsRepository.findEpisodeStats(download.id);
    if (stats?.durationMS == null) {
      final path = await _downloadPath.resolvePath(download);
      final mp3Info = MP3Processor.fromFile(File(path));
      await _episodeStatsRepository.updateEpisodeStats(
        EpisodeStatsUpdateParam(
          eid: download.id,
          pid: download.pid,
          ordinal: download.ordinal,
          duration: mp3Info.duration,
        ),
      );
    }
  }
}
