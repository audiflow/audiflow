import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/providers/podcast/podcast_subscriptions_provider.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';

part 'podcast_refresher_provider.g.dart';

@Riverpod(keepAlive: true)
class PodcastRefresher extends _$PodcastRefresher {
  final _log = Logger('PodcastRefresher');

  final _inputState = PublishSubject<List<(PodcastMetadata, PodcastStats)>>();
  Timer? _timer;
  (PodcastMetadata, PodcastStats)? _nextRefreshTarget;

  void dispose() {
    _inputState.close();
  }

  @override
  bool build() {
    _listen();
    return true;
  }

  void _listen() {
    ref.listen(
      podcastSubscriptionsProvider,
      (_, next) => next.whenData(_inputState.add),
      fireImmediately: true,
    );

    final sub = _inputState.stream
        .asyncMap(Future.value)
        .listen(_setupNextRefreshTarget);
    ref.onDispose(sub.cancel);
  }

  void _setupNextRefreshTarget(
    List<(PodcastMetadata, PodcastStats)> subscriptions,
  ) {
    _timer?.cancel();
    _timer = null;

    if (subscriptions.isEmpty) {
      _log.fine('no subscriptions');
      return;
    }

    final nextTarget =
        subscriptions.fold(subscriptions.first, (value, element) {
      if (value.$2.lastCheckedAt == null) {
        return value;
      } else if (element.$2.lastCheckedAt == null) {
        return element;
      } else {
        return value.$2.lastCheckedAt!.isBefore(element.$2.lastCheckedAt!)
            ? value
            : element;
      }
    });

    if (nextTarget.$1.guid == _nextRefreshTarget?.$1.guid && _timer == null) {
      return;
    }

    final delay = nextTarget.$2.lastCheckedAt == null
        ? Duration.zero
        : nextTarget.$2.lastCheckedAt!
            .add(const Duration(hours: 3))
            .difference(DateTime.now());

    _nextRefreshTarget = nextTarget;
    _timer = Timer(maxDuration(Duration.zero, delay), _refreshTarget);
    _log.fine('Next refresh target: ${nextTarget.$1.title} in $delay');
  }

  Future<void> _refreshTarget() async {
    _timer = null;
    if (_nextRefreshTarget == null) {
      return;
    }

    final podcast = _nextRefreshTarget!.$1;
    _log.fine('refresh target: ${podcast.title}');

    final loaded = await ref
        .read(podcastServiceProvider)
        .loadPodcast(podcast, refresh: true);
    if (loaded == null) {
      _timer = Timer(const Duration(minutes: 1), _refreshTarget);
    }
  }
}
