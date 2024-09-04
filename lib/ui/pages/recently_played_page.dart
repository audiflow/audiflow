// import 'package:audiflow/localization/generated/l10n.dart';
// import 'package:audiflow/ui/pages/app_bars/sub_page_app_bar.dart';
// import 'package:audiflow/features/browser/podcast/ui/episode_list.dart';
// import 'package:audiflow/ui/controllers/recently_played_episodes_provider.dart';
// import 'package:audiflow/common/ui/error_notifier.dart';
// import 'package:audiflow/common/ui/fill_remaining_error.dart';
// import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:scrolls_to_top/scrolls_to_top.dart';
//
// class RecentlyPlayedPage extends HookConsumerWidget {
//   const RecentlyPlayedPage({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(recentlyPlayedEpisodesProvider);
//
//     final controller = useScrollController();
//     return ScrollsToTop(
//       onScrollsToTop: (event) async {
//         await controller.animateTo(
//           event.to,
//           duration: event.duration,
//           curve: event.curve,
//         );
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             CustomScrollView(
//               controller: controller,
//               slivers: <Widget>[
//                 SubPageAppBar(title: L10n.of(context).recentlyPlayed),
//                 if (state.isLoading)
//                   const FillRemainingLoading()
//                 else if (state.hasError ||
//                     state.valueOrNull?.episodes.isEmpty == true)
//                   FillRemainingError.podcastNoResults()
//                 else
//                   EpisodeList(
//                     episodeGroupKey: const Key('recentlyPlayed'),
//                     episodes: state.value!.episodes,
//                     scrollController: controller,
//                   ),
//               ],
//             ),
//             const ErrorNotifier(),
//           ],
//         ),
//       ),
//     );
//   }
// }
