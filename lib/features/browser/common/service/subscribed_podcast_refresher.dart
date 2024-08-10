import 'dart:async';

import 'package:audiflow/features/browser/common/data/podcast_subscriptions.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'subscribed_podcast_refresher.g.dart';

@Riverpod(keepAlive: true)
class SubscribedPodcastRefresher extends _$SubscribedPodcastRefresher {
  final _inputState = PublishSubject<List<Podcast>>();

  // Timer? _timer;
  // (Podcast, PodcastStats)? _nextRefreshTarget;
  //
  // ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

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
    List<Podcast> subscriptions,
  ) {
    // _timer?.cancel();
    // _timer = null;
    //
    // if (subscriptions.isEmpty) {
    //   _log.fine('no subscriptions');
    //   return;
    // }
    //
    // final nextTarget =
    //     subscriptions.fold(subscriptions.first, (value, element) {
    //   if (value.$2.lastCheckedAt == null) {
    //     return value;
    //   } else if (element.$2.lastCheckedAt == null) {
    //     return element;
    //   } else {
    //     return value.$2.lastCheckedAt!.isBefore(element.$2.lastCheckedAt!)
    //         ? value
    //         : element;
    //   }
    // });
    //
    // if (nextTarget.$1.guid == _nextRefreshTarget?.$1.guid &&
    // _timer == null) {
    //   return;
    // }
    //
    // final delay = nextTarget.$2.lastCheckedAt == null
    //     ? Duration.zero
    //     : nextTarget.$2.lastCheckedAt!
    //         .add(const Duration(hours: 3))
    //         .difference(DateTime.now());
    //
    // _nextRefreshTarget = nextTarget;
    // _timer = Timer(maxDuration(Duration.zero, delay), _refreshTarget);
    // _log.fine('Next refresh target: ${nextTarget.$1.title} in $delay');
  }

// Future<void> _refreshTarget() async {
//   // _timer = null;
//   if (_nextRefreshTarget == null) {
//     return;
//   }
//
//   final podcast = _nextRefreshTarget!.$1;
//   logger.d('refresh target: ${podcast.title}');
//
//   try {
//     // final loaded = await ref
//     //     .read(podcastServiceProvider)
//     //     .loadPodcast(podcast, refresh: true);
//     // if (loaded != null) {
//     //   _log.fine('Podcast refreshed: ${podcast.title}');
//     // } else {
//     //   _log.warning('Failed to load podcast: ${podcast.title}');
//     //   await _repository.updatePodcastStats(
//     //     PodcastStatsUpdateParam(
//     //       id: podcast.id,
//     //       lastCheckedAt: DateTime.now(),
//     //     ),
//     //   );
//     // }
//   } on NetworkException catch (e) {
//     logger.w('Network error: e');
//     if (e is NoConnectivityException) {
//       _errorManager.retryOnReconnect(
//         key: 'refresh/${podcast.guid}',
//         retry: _refreshTarget,
//       );
//     // } else {
//     //   _timer = Timer(const Duration(minutes: 5), _refreshTarget);
//     }
//   }
// }
}
