// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
  String get forceHttps {
    if (this != null) {
      final url = Uri.tryParse(this!);

      if (url == null || !url.isScheme('http')) return this!;

      return url.replace(scheme: 'https').toString();
    }

    return this ?? '';
  }
}
