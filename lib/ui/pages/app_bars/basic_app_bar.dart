// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BasicAppBar extends HookConsumerWidget {
  const BasicAppBar({
    super.key,
    required this.titleBuilder,
    this.elevation,
  });

  BasicAppBar.chart({Key? key})
      : this(
          key: key,
          titleBuilder: (context) => 'Home',
        );

  BasicAppBar.search({Key? key})
      : this(
          key: key,
          titleBuilder: (context) => 'Search',
          elevation: 0,
        );

  final String Function(BuildContext) titleBuilder;
  final double? elevation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 100,
      elevation: elevation,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 20),
        title: Text(titleBuilder(context)),
      ),
    );
  }
}
