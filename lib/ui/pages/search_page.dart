// import 'package:audiflow/localization/generated/l10n.dart';
// import 'package:audiflow/events/podcast_search_event.dart';
// import 'package:audiflow/features/browser/common/ui/basic_app_bar.dart';
// import 'package:audiflow/ui/podcast/podcast_list.dart';
// import 'package:audiflow/ui/controllers/podcast_search_provider.dart';
// import 'package:audiflow/common/ui/error_notifier.dart';
// import 'package:audiflow/common/ui/fill_remaining_error.dart';
// import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:scrolls_to_top/scrolls_to_top.dart';
// import 'package:sliver_tools/sliver_tools.dart';
//
// class SearchPage extends HookConsumerWidget {
//   const SearchPage({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(podcastSearchProvider);
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
//                 BasicAppBar(title: L10n.of(context).search),
//                 const SliverPinnedHeader(child: SearchBar()),
//                 if (state.isLoading)
//                   const FillRemainingLoading()
//                 else if (state.hasError ||
//                     (state.valueOrNull?.notFound == true))
//                   FillRemainingError.podcastNoResults()
//                 else
//                   PodcastList(results: state.value!.podcasts),
//               ],
//             ),
//             const ErrorNotifier(),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class SearchBar extends HookConsumerWidget {
//   const SearchBar({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final searchController = useTextEditingController();
//     final searchFocusNode = useFocusNode();
//
//     final term = useState('');
//
//     useEffect(() {
//       void onChange() => term.value = searchController.text;
//       searchController.addListener(onChange);
//       return () => searchController.removeListener(onChange);
//     });
//
//     final theme = Theme.of(context);
//     return Semantics(
//       label: L10n.of(context).search_for_podcasts_hint,
//       textField: true,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
//         child: Container(
//           color: theme.colorScheme.surface,
//           foregroundDecoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: theme.dividerColor,
//               width: 0.5,
//             ),
//           ),
//           child: TextField(
//             controller: searchController,
//             focusNode: searchFocusNode,
//             autocorrect: false,
//             // autofocus: searchTerm != null,
//             keyboardType: TextInputType.text,
//             textInputAction: TextInputAction.search,
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: term.value.isEmpty
//                   ? null
//                   : IconButton(
//                       icon: const Icon(
//                         Icons.clear,
//                         size: 32,
//                       ),
//                       onPressed: searchController.clear,
//                     ),
//               hintText: L10n.of(context).search_for_podcasts_hint,
//               border: InputBorder.none,
//             ),
//             style: const TextStyle(fontSize: 18),
//             onSubmitted: (value) {
//               SemanticsService.announce(
//                 L10n.of(context).semantic_announce_searching,
//                 TextDirection.ltr,
//               );
//               ref
//                   .read(podcastSearchProvider.notifier)
//                   .input(NewPodcastSearchEvent(term: value));
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
