import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  group('NamedLogger', () {
    final seenNames = <String?>[];
    void recordName(LogEvent _) => seenNames.add(NamedLogger.dispatchingName);

    setUp(() {
      seenNames.clear();
      Logger.addLogListener(recordName);
    });

    tearDown(() => Logger.removeLogListener(recordName));

    test('exposes its name to log listeners during dispatch', () {
      NamedLogger('FeedSync').e('boom', error: StateError('x'));

      check(seenNames).deepEquals(['FeedSync']);
    });

    test('clears the name once the dispatch ends', () {
      NamedLogger('FeedSync').i('done');

      check(NamedLogger.dispatchingName).isNull();
    });

    test('reports no name for plain loggers', () {
      Logger(level: Level.off).e('boom');

      check(seenNames).deepEquals([null]);
    });
  });
}
