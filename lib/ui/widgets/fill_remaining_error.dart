// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:seasoning/l10n/L.dart';

class FillRemainingError extends StatelessWidget {
  const FillRemainingError({
    required this.icon,
    required this.messageBuilder,
    super.key,
  });

  FillRemainingError.podcastNoResults({Key? key})
      : this(
          icon: Icons.search,
          messageBuilder: (context) => L.of(context)!.no_search_results_message,
          key: key,
        );

  final IconData icon;
  final String Function(BuildContext context) messageBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 75,
              color: Theme.of(context).primaryColor,
            ),
            Text(
              messageBuilder(context),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
