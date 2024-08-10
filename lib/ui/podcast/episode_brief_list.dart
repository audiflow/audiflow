// import 'package:audiflow/entities/entities.dart';
// import 'package:audiflow/features/browser/episode/ui/episode_brief_tile.dart';
// import 'package:audiflow/common/ui/fill_remaining_error.dart';
// import 'package:flutter/material.dart';
//
// class EpisodeBriefList extends StatelessWidget {
//   const EpisodeBriefList({
//     super.key,
//     required this.episodes,
//   });
//
//   final List<Episode> episodes;
//
//   @override
//   Widget build(BuildContext context) {
//     if (episodes.isEmpty) {
//       return FillRemainingError.podcastNoResults();
//     }
//
//     return SliverSafeArea(
//       sliver: SliverList(
//         delegate: SliverChildBuilderDelegate(
//           (BuildContext context, int index) {
//             return EpisodeBriefTile(episode: episodes[index]);
//           },
//           childCount: episodes.length,
//           addAutomaticKeepAlives: false,
//         ),
//       ),
//     );
//   }
// }
