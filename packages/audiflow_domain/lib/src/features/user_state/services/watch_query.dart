import 'dart:async';

/// Emits [load]'s result on listen and again after each event of
/// [triggers], skipping a result [same] as the one before.
///
/// The triggers are subscribed before the first load, so a write that
/// lands while it runs is not missed. Loads run one at a time, in order.
Stream<T> watchQuery<T>({
  required List<Stream<void>> triggers,
  required Future<T> Function() load,
  required bool Function(T a, T b) same,
}) {
  late final StreamController<T> controller;
  final subscriptions = <StreamSubscription<void>>[];
  var pending = Future<void>.value();
  var active = false;
  var hasLast = false;
  late T last;

  void refresh() {
    pending = pending.then((_) async {
      if (!active) return;
      try {
        final value = await load();
        // Cancelled while loading: nobody listens any more.
        if (!active) return;
        if (hasLast && same(last, value)) return;
        hasLast = true;
        last = value;
        controller.add(value);
      } on Object catch (error, stack) {
        if (active) controller.addError(error, stack);
      }
    });
  }

  controller = StreamController<T>(
    onListen: () {
      active = true;
      for (final trigger in triggers) {
        subscriptions.add(
          trigger.listen((_) => refresh(), onError: controller.addError),
        );
      }
      refresh();
    },
    onCancel: () async {
      // Before awaiting, so refreshes queued behind a running load skip.
      active = false;
      for (final sub in subscriptions) {
        await sub.cancel();
      }
      subscriptions.clear();
    },
  );
  return controller.stream;
}
