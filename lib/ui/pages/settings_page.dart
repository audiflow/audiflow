// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/providers/podcast/podcast_search_provider.dart';
import 'package:audiflow/ui/pages/app_bars/basic_app_bar.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:audiflow/ui/widgets/fill_remaining_error.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastSearchProvider);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              BasicAppBar(title: L10n.of(context)!.settings),
              if (state.isLoading)
                const FillRemainingLoading()
              else if (state.hasError || (state.valueOrNull?.notFound == true))
                FillRemainingError.podcastNoResults()
              else
                FillRemainingError.podcastNoResults()
            ],
          ),
          const ErrorNotifier(),
        ],
      ),
    );
  }
}
