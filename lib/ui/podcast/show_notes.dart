// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/ui/widgets/podcast_html.dart';

/// This class displays the show notes for the selected podcast.
///
/// We make use of [Html] to render the notes and, if in HTML format, display the
/// correct formatting, links etc.
class ShowNotes extends StatelessWidget {

  ShowNotes({
    super.key,
    required this.episode,
  });
  final ScrollController _sliverScrollController = ScrollController();
  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
            controller: _sliverScrollController,
            slivers: <Widget>[
              SliverAppBar(
                title: Text(episode.podcast),
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(episode.title ?? '',
                          style: textTheme.titleLarge,),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: PodcastHtml(
                          content: episode.content ?? episode.description,),
                    ),
                  ],
                ),
              ),
            ],),);
  }
}
