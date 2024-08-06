import 'dart:async';
import 'dart:isolate';

import 'package:audiflow/common/data/isar_factory.dart';
import 'package:audiflow/exceptions/app_exception.dart';
import 'package:audiflow/features/browser/common/data/isar_stats_repository.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/episode/data/episode_list_entry_repository.dart';
import 'package:audiflow/features/browser/episode/data/isar_episode_list_repository.dart';
import 'package:audiflow/features/browser/episode/model/episode_list_entry.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/feed/data/isar_episode_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:worker_manager/worker_manager.dart';

class EpisodeListEntryPopulatorEvent {
  EpisodeListEntryPopulatorEvent({
    required this.total,
    required this.loaded,
  });

  final int total;
  final int loaded;
}

class EpisodeListEntryPopulator {
  EpisodeListEntryPopulator({
    required this.pid,
    required this.filterMode,
    required this.ascending,
    required this.role,
    required this.appDocDir,
    this.firstReadCount = 10,
  }) {
    _setupWorker();
  }

  final String appDocDir;
  final int pid;
  final EpisodeFilterMode filterMode;
  final bool ascending;
  final int firstReadCount;
  final EpisodeListEntryRole role;
  final _streamController = StreamController<EpisodeListEntryPopulatorEvent>();

  SendPort? _workerPort;

  Stream<EpisodeListEntryPopulatorEvent> get stream => _streamController.stream;

  void _setupWorker() {
    logger.i('setup worker');
    workerManager.executeGentleWithPort<void, _Message>(
      (sendPort, isCancelled) async {
        logger.d('start worker');
        final worker = _Worker(sendPort, isCancelled);
        await worker.listen();
        logger.d('worker done');
      },
      onMessage: _onWorkerMessage,
    ).whenComplete(() => _workerPort = null);
  }

  void dispose() {
    logger.d('dispose');
    _workerPort?.send(_CancelledCommand());
    _workerPort = null;
    _streamController.close();
  }

  Future<void> _onWorkerMessage(_Message message) async {
    logger.d(() => 'received $message');
    switch (message) {
      case _SendPortMessage(sendPort: final sendPort):
        _workerPort = sendPort;
        sendPort
          ..send(
            _SetupCommand(storageDir: appDocDir),
          )
          ..send(
            _LoadCommand(
              pid: pid,
              role: role,
              ascending: ascending,
              filterMode: filterMode,
              firstReadCount: firstReadCount,
            ),
          );
      case _LoadedMessage(
          total: final totalEpisodes,
          loadedCount: final loadedCount
        ):
        _streamController.add(
          EpisodeListEntryPopulatorEvent(
            total: totalEpisodes,
            loaded: loadedCount,
          ),
        );
      case _GotErrorMessage(error: final error):
        logger.w(message);
        _streamController.addError(error);
    }
  }
}

class _Worker {
  _Worker(
    this._uiPort,
    this._isCancelled,
  );

  final SendPort _uiPort;
  final ReceivePort _workerPort = ReceivePort();
  final bool Function() _isCancelled;

  late int _pid;
  late EpisodeListEntryRole _role;
  late EpisodeFilterMode _filterMode;
  late bool _ascending;
  late int _firstReadCount;
  static const int _batchReadCount = 3000;

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
              _role = command.role;
              _filterMode = command.filterMode;
              _ascending = command.ascending;
              _firstReadCount = command.firstReadCount;
              switch (_filterMode) {
                case EpisodeFilterMode.all:
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
          _uiPort.send(_GotErrorMessage(error: const UnknownException()));
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
            role: _role,
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
      _episodeListRepository.clear(_pid, _role),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total = (podcastStats as PodcastStats?)?.totalEpisodes ?? 0;

    var episodes = await _findEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }

    var loadedCount = episodes.length;
    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: loadedCount),
    );

    var lastOrdinal = episodes.last.ordinal;
    while (!_isCancelled() && loadedCount < total) {
      episodes = await _findEpisodes(
        limit: _batchReadCount,
        lastOrdinal: lastOrdinal,
      );
      await _saveEpisodeEntries(episodes, baseIndex: loadedCount);
      loadedCount += episodes.length;

      _uiPort.send(
        _LoadedMessage(
          total: episodes.length == _batchReadCount ? total : loadedCount,
          loadedCount: loadedCount,
        ),
      );
      if (episodes.length < _batchReadCount) {
        break;
      }
      lastOrdinal = episodes.last.ordinal;
    }
  }

  Future<List<Episode>> _findEpisodes({
    required int limit,
    int? lastOrdinal,
  }) {
    return _episodeRepository.queryEpisodes(
      pid: _pid,
      lastOrdinal: lastOrdinal,
      ascending: _ascending,
      limit: limit,
    );
  }

  // -- completed episodes

  Future<void> _loadCompletedEpisodes() async {
    final [count, _] = await Future.wait<dynamic>([
      _statsRepository.countEpisodeStatsBy(
        pid: _pid,
        filterBy: EpisodeStatsFilterBy.completed,
      ),
      _episodeListRepository.clear(_pid, _role),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total = count as int;
    if (total == 0) {
      _uiPort.send(
        _LoadedMessage(total: 0, loadedCount: 0),
      );
      return;
    }

    final episodes = await _findCompletedEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }

    var loadedCount = episodes.length;
    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: loadedCount),
    );

    while (!_isCancelled() && loadedCount < total) {
      final moreEpisodes = await _findCompletedEpisodes(
        limit: _batchReadCount,
        offset: loadedCount,
      );
      await _saveEpisodeEntries(moreEpisodes, baseIndex: loadedCount);
      loadedCount += moreEpisodes.length;

      _uiPort.send(
        _LoadedMessage(
          total: episodes.length == _batchReadCount ? total : loadedCount,
          loadedCount: loadedCount,
        ),
      );
      if (episodes.length < _batchReadCount) {
        break;
      }
    }
  }

  Future<List<Episode>> _findCompletedEpisodes({
    required int limit,
    int offset = 0,
  }) async {
    final statsList = await _statsRepository
        .findEpisodeStatsListBy(
          pid: _pid,
          filterBy: EpisodeStatsFilterBy.completed,
          sortBy: EpisodeStatsSortBy.playedDate,
          ascending: _ascending,
          limit: limit,
          offset: offset,
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
    return episodes;
  }

  // -- unplayed episodes

  Future<void> _loadUnplayedEpisodes() async {
    final [podcastStats, count, _] = await Future.wait<dynamic>([
      _statsRepository.findPodcastStats(_pid),
      _statsRepository.countEpisodeStatsBy(
        pid: _pid,
        filterBy: EpisodeStatsFilterBy.incomplete,
      ),
      _episodeListRepository.clear(_pid, _role),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total =
        ((podcastStats as PodcastStats?)?.totalEpisodes ?? 0) - (count as int);
    if (total == 0) {
      _uiPort.send(
        _LoadedMessage(total: 0, loadedCount: 0),
      );
      return;
    }

    var episodes = await _findUnplayedEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }

    var loadedCount = episodes.length;
    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: loadedCount),
    );
    if (total == 0) {
      return;
    }

    var lastOrdinal = episodes.last.ordinal;
    while (!_isCancelled() && loadedCount < total) {
      episodes = await _findUnplayedEpisodes(
        limit: _batchReadCount,
        lastOrdinal: lastOrdinal,
      );
      await _saveEpisodeEntries(episodes, baseIndex: loadedCount);
      loadedCount += episodes.length;

      _uiPort.send(
        _LoadedMessage(
          total: episodes.length == _batchReadCount ? total : loadedCount,
          loadedCount: loadedCount,
        ),
      );
      if (episodes.length < _batchReadCount) {
        break;
      }
    }
    lastOrdinal = episodes.last.ordinal;
  }

  Future<List<Episode>> _findUnplayedEpisodes({
    required int limit,
    int? lastOrdinal,
  }) async {
    final result = <Episode>[];
    var episodes = <Episode>[];
    var ordinal = lastOrdinal;
    while (result.length < limit) {
      episodes = await _findEpisodes(
        limit: limit,
        lastOrdinal: ordinal,
      );
      if (episodes.isEmpty) {
        break;
      }
      ordinal = episodes.last.ordinal;
      final statsList = await _statsRepository
          .findEpisodeStatsList(episodes.map((e) => e.id));
      final filtered = episodes
          .whereIndexed((i, e) => (statsList[i]?.completeCount ?? 0) < 1);
      result.addAll(filtered);

      if (episodes.length < limit) {
        break;
      }
    }
    return result;
  }

  // -- downloaded episodes

  Future<void> _loadDownloadedEpisodes() async {
    final [count, _] = await Future.wait<dynamic>([
      _downloadRepository.countDownloaded(pid: _pid),
      _episodeListRepository.clear(_pid, _role),
    ]);
    if (_isCancelled()) {
      return;
    }

    final total = count as int;
    if (total == 0) {
      _uiPort.send(
        _LoadedMessage(total: 0, loadedCount: 0),
      );
      return;
    }

    var episodes = await _findDownloadedEpisodes(limit: _firstReadCount);
    await _saveEpisodeEntries(episodes);
    if (_isCancelled()) {
      return;
    }

    var loadedCount = episodes.length;
    _uiPort.send(
      _LoadedMessage(total: total, loadedCount: loadedCount),
    );

    while (!_isCancelled() && loadedCount < total) {
      episodes = await _findDownloadedEpisodes(
        limit: _batchReadCount,
        offset: loadedCount,
      );
      await _saveEpisodeEntries(episodes, baseIndex: loadedCount);

      loadedCount += episodes.length;
      _uiPort.send(
        _LoadedMessage(
          total: episodes.length == _batchReadCount ? total : loadedCount,
          loadedCount: loadedCount,
        ),
      );
    }
  }

  Future<List<Episode>> _findDownloadedEpisodes({
    required int limit,
    int offset = 0,
  }) async {
    final downloads = await _downloadRepository.findDownloadsBy(
      pid: _pid,
      sortBy: DownloadSortBy.downloadStartedAt,
      ascending: _ascending,
      limit: limit,
      offset: offset,
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
    return episodes;
  }
}

sealed class _Command {}

sealed class _Message {}

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
    required this.role,
    required this.filterMode,
    required this.ascending,
    required this.firstReadCount,
  });

  final int pid;
  final EpisodeListEntryRole role;
  final EpisodeFilterMode filterMode;
  final bool ascending;
  final int firstReadCount;

  @override
  String toString() {
    return '_LoadCommand('
        'pid: $pid, '
        'role: $role, '
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
  _GotErrorMessage({required this.error});

  final AppException error;

  @override
  String toString() {
    return '_ErrorResult(error: $error)';
  }
}
