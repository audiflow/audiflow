import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_app_bar.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_image_and_title.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';

class PodcastDetailsLoadingPage extends StatelessWidget {
  const PodcastDetailsLoadingPage({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    super.key,
  });

  final String? title;
  final String? author;
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: false,
      label: L10n.of(context).semantics_podcast_details_header,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: <Widget>[
            PodcastDetailsAppBar(title: title),
            SliverToBoxAdapter(
              child: PodcastImageAndTitle(
                title: title ?? '',
                author: author,
                thumbnailUrl: thumbnailUrl,
              ),
            ),
            const FillRemainingLoading(),
          ],
        ),
      ),
    );
  }
}
