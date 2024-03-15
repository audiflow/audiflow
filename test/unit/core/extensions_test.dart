// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

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
