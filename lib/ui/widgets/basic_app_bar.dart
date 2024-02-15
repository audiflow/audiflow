// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BasicAppBar extends HookConsumerWidget {
  const BasicAppBar({super.key, required this.titleBuilder});

  BasicAppBar.chart({Key? key})
      : this(
          key: key,
          titleBuilder: (context) => 'Home',
        );
  final String Function(BuildContext) titleBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Text(titleBuilder(context)),
      ),
    );
  }
}
