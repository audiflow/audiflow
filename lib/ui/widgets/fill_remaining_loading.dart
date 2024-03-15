// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/ui/widgets/platform_progress_indicator.dart';
import 'package:flutter/material.dart';

class FillRemainingLoading extends StatelessWidget {
  const FillRemainingLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          PlatformProgressIndicator(),
        ],
      ),
    );
  }
}
