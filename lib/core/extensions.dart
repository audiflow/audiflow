import 'package:collection/collection.dart';

extension IterableExtensions<E> on Iterable<E> {
  Iterable<List<E>> chunk(int size) sync* {
    var group = 0;
    var n = 0;

    final chunks = groupListsBy((element) {
      if (n++ == size) {
        n = 1;
        group++;
      }
      return group;
    });
    for (final e in chunks.values) {
      yield e;
    }
  }
}

extension ExtString on String? {
  String? get forceHttps => this?.replaceFirst(RegExp(r'^http://'), 'https://');
}
