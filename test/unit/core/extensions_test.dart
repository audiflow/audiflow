import 'package:flutter_test/flutter_test.dart';
import 'package:seasoning/core/extensions.dart';

void main() {
  final testCases = [
    {
      'data': <int>[1, 2, 3, 4, 5],
      'expects': [
        [1, 2],
        [3, 4],
        [5],
      ],
    },
    {
      'data': <int>[1, 2, 3, 4],
      'expects': [
        [1, 2],
        [3, 4],
      ],
    },
    {'data': <int>[], 'expects': <int>[]},
  ];

  test(
    'chunk',
    () {
      for (final tt in testCases) {
        expect(tt['data']!.chunk(2), tt['expects']);
      }
    },
  );
}
