import 'package:audiflow_app/features/car/models/car_list_item.dart';
import 'package:audiflow_app/features/car/services/car_change_batcher.dart';
import 'package:checks/checks.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const delay = Duration(milliseconds: 500);
  late List<Set<CarSection>> flushed;
  late CarChangeBatcher batcher;

  setUp(() {
    flushed = [];
    batcher = CarChangeBatcher(onFlush: flushed.add, delay: delay);
  });

  test('reports a burst of changes once, merged', () {
    fakeAsync((async) {
      batcher
        ..add({CarSection.upNext})
        ..add({CarSection.upNext, CarSection.downloads});
      async.elapse(delay);

      check(flushed).deepEquals([
        {CarSection.upNext, CarSection.downloads},
      ]);
    });
  });

  test('waits for the delay before reporting', () {
    fakeAsync((async) {
      batcher.add({CarSection.library});
      async.elapse(delay - const Duration(milliseconds: 1));

      check(flushed).isEmpty();
    });
  });

  test('starts a new burst after a report', () {
    fakeAsync((async) {
      batcher.add({CarSection.library});
      async.elapse(delay);
      batcher.add({CarSection.inProgress});
      async.elapse(delay);

      check(flushed).deepEquals([
        {CarSection.library},
        {CarSection.inProgress},
      ]);
    });
  });

  test('clear drops pending changes', () {
    fakeAsync((async) {
      batcher
        ..add({CarSection.upNext})
        ..clear();
      async.elapse(delay);

      check(flushed).isEmpty();
    });
  });
}
