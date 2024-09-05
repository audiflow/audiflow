part of 'podcast_feed_loader.dart';

sealed class _Command {}

sealed class _Message {}

class _SendPortMessage extends _Message {
  _SendPortMessage(this.sendPort);

  final SendPort sendPort;

  @override
  String toString() {
    return '_SendPortEvent{sendPort}';
  }
}

class _SetupCommand extends _Command {
  _SetupCommand({
    required this.cacheDir,
    required this.storageDir,
  });

  final String cacheDir;
  final String storageDir;

  @override
  String toString() {
    return '_SetupCommand(cacheDir: $cacheDir, storageDir: $storageDir)';
  }
}

class _LoadFeedCommand extends _Command {
  _LoadFeedCommand({
    required this.feedUrl,
    required this.collectionId,
  });

  final String feedUrl;
  final int? collectionId;

  @override
  String toString() {
    return '_LoadFeedCommand('
        'feedUrl: $feedUrl, '
        'collectionId: $collectionId)';
  }
}

class _ContinueEpisodeLoadingCommand extends _Command {
  _ContinueEpisodeLoadingCommand();

  @override
  String toString() {
    return '_ContinueEpisodeLoadingCommand()';
  }
}

class _LoadedPodcastMessage extends _Message {
  _LoadedPodcastMessage();

  @override
  String toString() {
    return '_LoadedPodcastMessage()';
  }
}

class _LoadedEpisodesMessage extends _Message {
  _LoadedEpisodesMessage({
    required this.episodes,
    required this.loadingState,
  });

  final List<PartialEpisode> episodes;
  final LoadingState loadingState;

  @override
  String toString() {
    return '_LoadedEpisodesMessage('
        'episodes: ${episodes.length} episodes, '
        'loadingState: $loadingState)';
  }
}

class _LoadedSeasonMessage extends _Message {
  _LoadedSeasonMessage({
    required this.seasons,
  });

  final List<Season> seasons;

  @override
  String toString() {
    return '_LoadedSeasonMessage(seasons: ${seasons.length} seasons)';
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
