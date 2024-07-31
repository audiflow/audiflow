import 'dart:async';
import 'dart:isolate';

import 'package:audiflow/common/data/app_path_repository.dart';
import 'package:audiflow/common/data/isar_factory.dart';
import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/events/download_event.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/browser/common/data/isar_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/episode/data/episode_list_entry_repository.dart';
import 'package:audiflow/features/browser/episode/data/isar_episode_list_repository.dart';
import 'package:audiflow/features/browser/episode/model/episode_list_entry.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:worker_manager/worker_manager.dart';

part 'episode_list_controller.freezed.dart';
part 'episode_list_controller.g.dart';

@riverpod
class EpisodeListController extends _$EpisodeListController {
  SendPort? _workerPort;

  String get _appDocDir => ref.read(appDocDirProvider);

  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  StatsRepository get _statsRepository => ref.read(statsRepositoryProvider);

  EpisodeListEntryRepository get _episodeListEntryRepository =>
      ref.read(episodeListEntryRepositoryProvider);

  final _completer = Completer<(int, int, String?)>();

  @override
  Future<EpisodeListState> build({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascending,
    int episodesPerPage = 10,
  }) async {
    logger.d(
      () => 'build (pid: $pid, filterMode: $filterMode, ascend: $ascending,'
          ' episodesPerPage: $episodesPerPage)',
    );

    await _setupWorker();
    _listen();

    return _completer.future.then((message) {
      final (totalEpisodes, loadedCount, errorMessage) = message;
      return EpisodeListState(
        pid: pid,
        filterMode: filterMode,
        ascend: ascending,
        episodesPerPage: episodesPerPage,
        totalEpisodes: totalEpisodes,
        loadedCount: loadedCount,
        errorMessage: errorMessage,
      );
    });
  }

  Future<void> _setupWorker() async {
    logger.i('setup worker');
    final cancellable = workerManager.executeGentleWithPort<void, _Message>(
      (sendPort, isCancelled) async {
        logger.d('start worker');
        final worker = _Worker(sendPort, isCancelled);
        await worker.listen();
        logger.d('worker done');
      },
      onMessage: _onWorkerMessage,
    );
    unawaited(cancellable.whenComplete(() => _workerPort = null));

    ref.onDispose(() {
      logger.d('dispose');
      _workerPort?.send(_CancelledCommand());
      _workerPort = null;
    });
  }

  Future<Episode?> getEpisodeAt(int index) async {
    if (index < (state.valueOrNull?.loadedCount ?? 0)) {
      final entry =
          await _episodeListEntryRepository.findBy(pid: pid, order: index);
      return entry == null ? null : _episodeRepository.findEpisode(entry.eid);
    } else if (state.requireValue.totalEpisodes <= index) {
      return null;
    }

    final completer = Completer<Episode?>();
    ref
      ..listenSelf((_, next) {
        if (completer.isCompleted) {
          return;
        }
        next.whenData(
          (value) async {
            if (index < value.loadedCount) {
              final entry = await _episodeListEntryRepository.findBy(
                pid: pid,
                order: index,
              );
              final episode = entry == null
                  ? null
                  : _episodeRepository.findEpisode(entry.eid);
              completer.complete(episode);
            } else if (state.requireValue.totalEpisodes <= index) {
              completer.complete(null);
            }
          },
        );
      })
      ..onDispose(() {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });
    return completer.future;
  }

  Future<int?> getLastPlayedIndex() async {
    final episodes = await _statsRepository.findEpisodeStatsListBy(
      pid: pid,
      sortBy: EpisodeStatsSortBy.playedDate,
      limit: 1,
    );
    if (episodes.isEmpty) {
      return null;
    }
    final entry = await _episodeListEntryRepository.findBy(
      pid: pid,
      eid: episodes.first!.id,
    );
    return entry?.order;
  }

  Future<void> _onWorkerMessage(_Message message) async {
    logger.d(() => 'received $message');
    switch (message) {
      case _SendPortMessage(sendPort: final sendPort):
        _workerPort = sendPort;
        sendPort
          ..send(
            _SetupCommand(storageDir: _appDocDir),
          )
          ..send(
            _LoadCommand(
              pid: pid,
              ascending: ascending,
              filterMode: filterMode,
              firstReadCount: episodesPerPage,
            ),
          );
      case _LoadedMessage(
          total: final totalEpisodes,
          loadedCount: final loadedCount
        ):
        if (!_completer.isCompleted) {
          _completer.complete((totalEpisodes, loadedCount, null));
        } else {
          state = AsyncData(
            state.requireValue.copyWith(
              totalEpisodes: totalEpisodes,
              loadedCount: loadedCount,
            ),
          );
        }
      case _GotErrorMessage(message: final message):
        logger.w(message);
        if (!_completer.isCompleted) {
          _completer.complete((0, 0, message));
        } else {
          state = AsyncError(message, StackTrace.current);
        }
    }
  }

  void _listen() {
    void sendReloadCommand() {
      _workerPort?.send(
        _LoadCommand(
          pid: pid,
          ascending: ascending,
          filterMode: filterMode,
          firstReadCount: episodesPerPage,
        ),
      );
    }

    ref
      ..listen(podcastEventStreamProvider, (_, next) {
        if (next.requireValue
            case PodcastStatsUpdatedEvent(stats: final stats)) {
          if (stats.id == pid &&
              state.hasValue &&
              stats.totalEpisodes != state.requireValue.totalEpisodes) {
            sendReloadCommand();
          }
        }
      })
      ..listen(downloadEventStreamProvider, (_, next) {
        if (filterMode != EpisodeFilterMode.downloaded) {
          return;
        }
        if (next.requireValue
            case DownloadUpdatedEvent(download: final download) ||
                DownloadDeletedEvent(download: final download)) {
          if (download.pid == pid &&
              download.state == DownloadState.downloaded) {
            sendReloadCommand();
          }
        }
      })
      ..listen(audioPlayerEventStreamProvider, (_, next) {
        if ([
          EpisodeFilterMode.unplayed,
          EpisodeFilterMode.completed,
        ].contains(filterMode)) {
          return;
        }

        if (next.requireValue
            case AudioPlayerActionEvent(
              episode: final episode,
              action: final action
            )) {
          if (episode.pid == pid && action == AudioPlayerAction.completed) {
            sendReloadCommand();
          }
        }
      });
  }
}

@freezed
class EpisodeListState with _$EpisodeListState {
  const factory EpisodeListState({
    required int pid,
    required EpisodeFilterMode filterMode,
    required bool ascend,
    required int episodesPerPage,
    required int totalEpisodes,
    @Default(0) int loadedCount,
    String? errorMessage,
  }) = _EpisodeListState;
}

sealed class _Command {}

sealed class _Message {}

class _Worker {
  _Worker(
    this._uiPort,
    this._isCancelled,
  );

  final SendPort _uiPort;
  final ReceivePort _workerPort = ReceivePort();
  final bool Function() _isCancelled;

  late final int _pid;
  late final EpisodeFilterMode _filterMode;
  late final bool _ascending;
  late final int _firstReadCount;
  static const int _batchReadCount = 100;

  late final Isar _isar;
  late final EpisodeRepository _episodeRepository;
  late final StatsRepository _statsRepository;
  late final DownloadRepository _downloadRepository;
  late final EpisodeListEntryRepository _episodeListRepository;
  final _commandStreamController = StreamController<_Command>();
  final _completer = Completer<void>();

  void dispose() {
    _commandStreamController.close();
    _isar.close();
  }

  Future<void> listen() async {
    _listenCommandStream();
    _workerPort.listen((event) {
      _commandStreamController.add(event as _Command);
    });
    _uiPort.send(_SendPortMessage(_workerPort.sendPort));
    return _completer.future;
  }

  void _listenCommandStream() {
    _commandStreamController.stream.flatMap(
      (command) async* {
        logger.d(() => 'received command $command');
        try {
          switch (command) {
            case _SetupCommand(storageDir: final storageDir):
              await _setupRepository(storageDir);
            case _LoadCommand():
              _pid = command.pid;
              _filterMode = command.filterMode;
              _ascending = command.ascending;
              _firstReadCount = command.firstReadCount;
              switch (_filterMode) {
                case EpisodeFilterMode.none:
                  await _loadAllEpisodes();
                case EpisodeFilterMode.completed:
                  await _loadCompletedEpisodes();
                case EpisodeFilterMode.unplayed:
                  await _loadUnplayedEpisodes();
                case EpisodeFilterMode.downloaded:
                  await _loadDownloadedEpisodes();
              }
            case _CancelledCommand():
              _complete();
          }
          // ignore: avoid_catches_without_on_clauses
        } catch (err) {
          logger.e(err);
          _uiPort.send(_GotErrorMessage(message: err.toString()));
        }
      },
      maxConcurrent: 1,
    ).drain<void>();
  }

  void _complete() {
    if (!_completer.isCompleted) {
      _completer.complete(null);
    }
  }

  Future<void> _setupRepository(String storageDir) async {
    _isar = await IsarFactory.create(storageDir);
    _episodeRepository = IsarEpisodeRepository(_isar);
    _statsRepository = IsarStatsRepository(_isar);
    _episodeListRepository = IsarEpisodeListEntryRepository(_isar);
  }

  Future<void> _saveEpisodeEntries(
    List<Episode> episodes, {
    int baseIndex = 0,
  }) async {
    final entries = episodes
        .mapIndexed(
          (i, e) => EpisodeListEntry(
            pid: _pid,
            eid: e.id,
            order: baseIndex + i,
          ),
        )
        .toList();
    await _episodeListRepository.addAll(entries);
  }

  // -- all episodes

  Future<void> _loadAllEpisodes() async {
    final [podcastStats, _] = await Future.wait<dynamic>([
      _statsRepository.findPodcastStats(_pid),
      _episodeListRepository.clear(_pid),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total = (podcastStats as PodcastStats?)?.totalEpisodes ?? 0;

    final episodes = await _findEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }
    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: episodes.length),
    );

    while (!_isCancelled() && episodes.length < total) {
      final more = await _findEpisodes(
        limit: _batchReadCount,
        lastPubDate: episodes.last.publicationDate,
      );
      await _saveEpisodeEntries(more, baseIndex: episodes.length);
      episodes.addAll(more);

      _uiPort.send(
        _LoadedMessage(total: total, loadedCount: episodes.length),
      );
    }
  }

  Future<List<Episode>> _findEpisodes({
    required int limit,
    DateTime? lastPubDate,
  }) {
    return _episodeRepository.findEpisodesBy(
      pid: _pid,
      lastPubDate: lastPubDate,
      sortBy: EpisodeSortBy.pubDate,
      ascending: _ascending,
      limit: 1000,
    );
  }

  // -- completed episodes

  Future<void> _loadCompletedEpisodes() async {
    final [count, _] = await Future.wait<dynamic>([
      _statsRepository.countEpisodeStatsBy(
        pid: _pid,
        filterBy: EpisodeStatsFilterBy.completed,
      ),
      _episodeListRepository.clear(_pid),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total = count as int;
    if (total == 0) {
      _uiPort.send(
        _LoadedMessage(total: total, loadedCount: 0),
      );
      return;
    }

    final (statsList, episodes) =
        await _findCompletedEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }

    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: episodes.length),
    );

    while (!_isCancelled() && episodes.length < total) {
      final (moreStatsList, moreEpisodes) = await _findCompletedEpisodes(
        limit: _batchReadCount,
        lastPlayedDate: statsList.last.lastPlayedAt,
      );
      await _saveEpisodeEntries(moreEpisodes, baseIndex: episodes.length);
      statsList.addAll(moreStatsList);
      episodes.addAll(moreEpisodes);

      _uiPort.send(
        _LoadedMessage(total: total, loadedCount: episodes.length),
      );
    }
  }

  Future<(List<EpisodeStats>, List<Episode>)> _findCompletedEpisodes({
    required int limit,
    DateTime? lastPlayedDate,
  }) async {
    final statsList = await _statsRepository
        .findEpisodeStatsListBy(
          pid: _pid,
          filterBy: EpisodeStatsFilterBy.completed,
          sortBy: EpisodeStatsSortBy.playedDate,
          lastPlayedDate: lastPlayedDate,
          ascending: _ascending,
          limit: limit,
        )
        .then((list) => list.whereNotNull().toList());

    final episodes = await _episodeRepository
        .findEpisodes(statsList.map((e) => e.id))
        .then((list) => list.whereNotNull())
        .then(
          (list) => list.sorted((a, b) {
            final ia = statsList.indexWhere((e) => e.id == a.id);
            final ib = statsList.indexWhere((e) => e.id == a.id);
            return ia - ib;
          }),
        );
    return (statsList, episodes);
  }

  // -- unplayed episodes

  Future<void> _loadUnplayedEpisodes() async {
    final [podcastStats, count, _] = await Future.wait<dynamic>([
      _statsRepository.findPodcastStats(_pid),
      _statsRepository.countEpisodeStatsBy(
        pid: _pid,
        filterBy: EpisodeStatsFilterBy.incomplete,
      ),
      _episodeListRepository.clear(_pid),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total =
        ((podcastStats as PodcastStats?)?.totalEpisodes ?? 0) - (count as int);
    if (total == 0) {
      _uiPort.send(
        _LoadedMessage(total: total, loadedCount: 0),
      );
      return;
    }

    final episodes = await _findUnplayedEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }

    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: episodes.length),
    );
    if (total == 0) {
      return;
    }

    while (!_isCancelled() && episodes.length < total) {
      final more = await _findUnplayedEpisodes(
        limit: _batchReadCount,
        lastPubDate: episodes.lastOrNull?.publicationDate,
      );
      await _saveEpisodeEntries(more, baseIndex: episodes.length);
      episodes.addAll(more);

      _uiPort.send(
        _LoadedMessage(total: total, loadedCount: episodes.length),
      );
    }
  }

  Future<List<Episode>> _findUnplayedEpisodes({
    required int limit,
    DateTime? lastPubDate,
  }) async {
    final result = <Episode>[];
    var episodes = <Episode>[];
    while (result.length < limit) {
      episodes = await _findEpisodes(
        limit: _batchReadCount,
        lastPubDate: episodes.lastOrNull?.publicationDate ?? lastPubDate,
      );
      if (episodes.isEmpty) {
        break;
      }
      final statsList = await _statsRepository
          .findEpisodeStatsList(episodes.map((e) => e.id));
      final filtered = episodes
          .whereIndexed((i, e) => (statsList[i]?.completeCount ?? 0) < 1);
      result.addAll(filtered);

      if (episodes.length < _batchReadCount) {
        // shortcut
        break;
      }
    }
    return result;
  }

  // -- downloaded episodes

  Future<void> _loadDownloadedEpisodes() async {
    final [count, _] = await Future.wait<dynamic>([
      _downloadRepository.countDownloaded(pid: _pid),
      _episodeListRepository.clear(_pid),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total = count as int;
    if (total == 0) {
      _uiPort.send(
        _LoadedMessage(total: total, loadedCount: 0),
      );
      return;
    }

    final (downloadedList, episodes) =
        await _findDownloadedEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }

    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: episodes.length),
    );

    while (!_isCancelled() && episodes.length < total) {
      final (moreStatsList, moreEpisodes) = await _findDownloadedEpisodes(
        limit: _batchReadCount,
        lastDownloadStartedAt: downloadedList.last.downloadStartedAt,
      );
      await _saveEpisodeEntries(moreEpisodes, baseIndex: episodes.length);
      downloadedList.addAll(moreStatsList);
      episodes.addAll(moreEpisodes);

      _uiPort.send(
        _LoadedMessage(total: total, loadedCount: episodes.length),
      );
    }
  }

  Future<(List<Downloadable>, List<Episode>)> _findDownloadedEpisodes({
    required int limit,
    DateTime? lastDownloadStartedAt,
  }) async {
    final downloads = await _downloadRepository.findDownloadsBy(
      pid: _pid,
      lastDownloadStartedAt: lastDownloadStartedAt,
      sortBy: DownloadSortBy.downloadStartedAt,
      ascending: _ascending,
      limit: limit,
    );
    final episodes = await _episodeRepository
        .findEpisodes(downloads.map((e) => e.eid).whereNotNull())
        .then((list) => list.whereNotNull())
        .then(
          (list) => list.sorted((a, b) {
            final ia = downloads.indexWhere((e) => e.eid == a.id);
            final ib = downloads.indexWhere((e) => e.eid == a.id);
            return ia - ib;
          }),
        );
    return (downloads, episodes);
  }
}

class _SendPortMessage extends _Message {
  _SendPortMessage(this.sendPort);

  final SendPort sendPort;

  @override
  String toString() {
    return '_SendPortEvent(sendPort)';
  }
}

class _SetupCommand extends _Command {
  _SetupCommand({
    required this.storageDir,
  });

  final String storageDir;

  @override
  String toString() {
    return '_SetupCommand(storageDir: $storageDir)';
  }
}

class _LoadCommand extends _Command {
  _LoadCommand({
    required this.pid,
    required this.filterMode,
    required this.ascending,
    required this.firstReadCount,
  });

  final int pid;
  final EpisodeFilterMode filterMode;
  final bool ascending;
  final int firstReadCount;

  @override
  String toString() {
    return '_LoadCommand('
        'pid: $pid, '
        'filterMode: $filterMode, '
        'ascending: $ascending, '
        'firstReadCount: $firstReadCount)';
  }
}

class _LoadedMessage extends _Message {
  _LoadedMessage({
    required this.total,
    required this.loadedCount,
  });

  final int total;
  final int loadedCount;

  @override
  String toString() {
    return '_LoadedMessage(total: $total, loadedCount: $loadedCount)';
  }
}

class _CancelledCommand extends _Command {
  _CancelledCommand();

  @override
  String toString() {
    return '_CancelledCommand()';
  }
}

class _GotErrorMessage extends _Message {
  _GotErrorMessage({required this.message});

  final String message;

  @override
  String toString() {
    return '_ErrorResult(message: $message)';
  }
}
