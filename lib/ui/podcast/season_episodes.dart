// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dialogs/flutter_dialogs.dart';
// import 'package:logging/logging.dart';
// import 'package:provider/provider.dart';
// import 'package:seasoning/bloc/podcast/podcast_bloc.dart';
// import 'package:seasoning/bloc/settings/settings_bloc.dart';
// import 'package:seasoning/entities/podcast.dart';
// import 'package:seasoning/entities/season.dart';
// import 'package:seasoning/events/bloc_state.dart';
// import 'package:seasoning/l10n/L.dart';
// import 'package:seasoning/ui/podcast/podcast_episode_list.dart';
// import 'package:seasoning/ui/widgets/action_text.dart';
// import 'package:seasoning/ui/widgets/delayed_progress_indicator.dart';
// import 'package:seasoning/ui/widgets/placeholder_builder.dart';
// import 'package:seasoning/ui/widgets/platform_back_button.dart';
// import 'package:seasoning/ui/widgets/podcast_html.dart';
// import 'package:seasoning/ui/widgets/podcast_image.dart';
//
// /// This Widget takes podcast and its season and builds a list of episodes under the season.
// class SeasonEpisodes extends StatefulWidget {
//   const SeasonEpisodes(
//     this.season, {
//     super.key,
//   });
//
//   final Season season;
//
//   @override
//   State<SeasonEpisodes> createState() => _SeasonEpisodesState();
// }
//
// class _SeasonEpisodesState extends State<SeasonEpisodes> {
//   final log = Logger('SeasonEpisodes');
//   final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
//   final ScrollController _sliverScrollController = ScrollController();
//   Brightness brightness = Brightness.dark;
//   bool toolbarCollapsed = false;
//   SystemUiOverlayStyle? _systemOverlayStyle;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Load the details of the Podcast specified in the URL
//     log.fine('initState() - load feed');
//
//     // We only want to display the podcast title when the toolbar is in a
//     // collapsed state. Add a listener and set toolbarCollapsed variable
//     // as required. The text display property is then based on this boolean.
//     _sliverScrollController.addListener(() {
//       if (!toolbarCollapsed &&
//           _sliverScrollController.hasClients &&
//           _sliverScrollController.offset > (300 - kToolbarHeight)) {
//         setState(() {
//           toolbarCollapsed = true;
//           _updateSystemOverlayStyle();
//         });
//       } else if (toolbarCollapsed &&
//           _sliverScrollController.hasClients &&
//           _sliverScrollController.offset < (300 - kToolbarHeight)) {
//         setState(() {
//           toolbarCollapsed = false;
//           _updateSystemOverlayStyle();
//         });
//       }
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     _systemOverlayStyle = SystemUiOverlayStyle(
//       statusBarIconBrightness: Theme.of(context).brightness == Brightness.light
//           ? Brightness.dark
//           : Brightness.light,
//       statusBarColor: Theme.of(context)
//           .appBarTheme
//           .backgroundColor!
//           .withOpacity(toolbarCollapsed ? 1.0 : 0.5),
//     );
//     super.didChangeDependencies();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   void _resetSystemOverlayStyle() {
//     setState(() {
//       _systemOverlayStyle = SystemUiOverlayStyle(
//         statusBarIconBrightness:
//             Theme.of(context).brightness == Brightness.light
//                 ? Brightness.dark
//                 : Brightness.light,
//         statusBarColor: Colors.transparent,
//       );
//     });
//   }
//
//   void _updateSystemOverlayStyle() {
//     setState(() {
//       _systemOverlayStyle = SystemUiOverlayStyle(
//         statusBarIconBrightness:
//             Theme.of(context).brightness == Brightness.light
//                 ? Brightness.dark
//                 : Brightness.light,
//         statusBarColor: Theme.of(context)
//             .appBarTheme
//             .backgroundColor!
//             .withOpacity(toolbarCollapsed ? 1.0 : 0.5),
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final podcastBloc = Provider.of<PodcastBloc>(context, listen: false);
//     final placeholderBuilder = PlaceholderBuilder.of(context);
//
//     return Semantics(
//       header: false,
//       label: L.of(context)!.semantics_podcast_details_header,
//       child: PopScope(
//         onPopInvoked: (didPop) {
//           _resetSystemOverlayStyle();
//         },
//         child: ScaffoldMessenger(
//           key: scaffoldMessengerKey,
//           child: Scaffold(
//             backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//             body: CustomScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               controller: _sliverScrollController,
//               slivers: <Widget>[
//                 SliverAppBar(
//                   systemOverlayStyle: _systemOverlayStyle,
//                   title: AnimatedOpacity(
//                     opacity: toolbarCollapsed ? 1.0 : 0.0,
//                     duration: const Duration(milliseconds: 500),
//                     child: Text(widget.season.title ?? 'Extra'),
//                   ),
//                   leading: PlatformBackButton(
//                     iconColour: toolbarCollapsed &&
//                             Theme.of(context).brightness == Brightness.light
//                         ? Theme.of(context).appBarTheme.foregroundColor!
//                         : Colors.white,
//                     decorationColour: toolbarCollapsed
//                         ? const Color(0x00000000)
//                         : const Color(0x22000000),
//                     onPressed: () {
//                       _resetSystemOverlayStyle();
//                       Navigator.pop(context);
//                     },
//                   ),
//                   expandedHeight: 300,
//                   pinned: true,
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Hero(
//                       key: Key('seasonhero${widget.season.guid}'),
//                       tag: widget.season.guid,
//                       child: ExcludeSemantics(
//                         child: SeasonHeaderImage(
//                           season: widget.season,
//                           placeholderBuilder: placeholderBuilder,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // StreamBuilder<BlocState<Podcast>>(
//                 //     initialData: BlocEmptyState<Podcast>(),
//                 //     stream: podcastBloc.details,
//                 //     builder: (context, snapshot) {
//                 //       final state = snapshot.data;
//                 //
//                 //       if (state is BlocLoadingState) {
//                 //         return const SliverToBoxAdapter(
//                 //           child: Padding(
//                 //             padding: EdgeInsets.all(24.0),
//                 //             child: Column(
//                 //               children: <Widget>[
//                 //                 PlatformProgressIndicator(),
//                 //               ],
//                 //             ),
//                 //           ),
//                 //         );
//                 //       }
//                 //
//                 //       if (state is BlocErrorState) {
//                 //         return SliverFillRemaining(
//                 //           hasScrollBody: false,
//                 //           child: Padding(
//                 //             padding: const EdgeInsets.all(32.0),
//                 //             child: Column(
//                 //               mainAxisAlignment: MainAxisAlignment.center,
//                 //               crossAxisAlignment: CrossAxisAlignment.center,
//                 //               children: <Widget>[
//                 //                 const Icon(
//                 //                   Icons.error_outline,
//                 //                   size: 50,
//                 //                 ),
//                 //                 Text(
//                 //                   L.of(context)!.no_podcast_details_message,
//                 //                   style: Theme.of(context).textTheme.bodyMedium,
//                 //                   textAlign: TextAlign.center,
//                 //                 ),
//                 //               ],
//                 //             ),
//                 //           ),
//                 //         );
//                 //       }
//                 //
//                 //       if (state is BlocPopulatedState<Podcast>) {
//                 //         return SliverToBoxAdapter(
//                 //             child: PlaybackErrorListener(
//                 //           child: Column(
//                 //             crossAxisAlignment: CrossAxisAlignment.start,
//                 //             children: <Widget>[
//                 //               Padding(
//                 //       padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 2.0),
//                 //       child: Text(widget.season.title ?? 'Extra', style: textTheme.titleLarge),
//                 //     ),
//                 //               const Divider(),
//                 //             ],
//                 //           ),
//                 //         ));
//                 //       }
//                 //
//                 //       return const SliverToBoxAdapter(
//                 //         child: SizedBox(
//                 //           width: 0.0,
//                 //           height: 0.0,
//                 //         ),
//                 //       );
//                 //     }),
//                 PodcastEpisodeList(
//                   episodes: widget.season.episodes,
//                   play: true,
//                   download: true,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// Renders the podcast or episode image.
// class SeasonHeaderImage extends StatelessWidget {
//   const SeasonHeaderImage({
//     super.key,
//     required this.season,
//     required this.placeholderBuilder,
//   });
//
//   final Season season;
//   final PlaceholderBuilder? placeholderBuilder;
//
//   @override
//   Widget build(BuildContext context) {
//     if (season.imageUrl == null || season.imageUrl!.isEmpty) {
//       return const SizedBox(
//         height: 560,
//         width: 560,
//       );
//     }
//
//     return PodcastBannerImage(
//       key: Key('details${season.imageUrl}'),
//       url: season.imageUrl!,
//       placeholder: placeholderBuilder != null
//           ? placeholderBuilder?.builder()(context)
//           : DelayedCircularProgressIndicator(),
//       errorPlaceholder: placeholderBuilder != null
//           ? placeholderBuilder?.errorBuilder()(context)
//           : const Image(
//               image: AssetImage('assets/images/anytime-placeholder-logo.png'),
//             ),
//     );
//   }
// }
//
// /// Renders the podcast title, copyright, description, follow/unfollow and
// /// overflow button.
// ///
// /// If the episode description is fairly long, an overflow icon is also shown
// /// and a portion of the episode description is shown. Tapping the overflow
// /// icons allows the user to expand and collapse the text.
// ///
// /// Description is rendered by [PodcastDescription].
// /// Follow/Unfollow button rendered by [FollowButton].
// class SeasonTitle extends StatefulWidget {
//   const SeasonTitle(this.season, {super.key});
//
//   final Season season;
//
//   @override
//   State<SeasonTitle> createState() => _SeasonTitleState();
// }
//
// class _SeasonTitleState extends State<SeasonTitle> {
//   final GlobalKey descriptionKey = GlobalKey();
//   final maxHeight = 100.0;
//   PodcastHtml? description;
//   bool showOverflow = false;
//   final StreamController<bool> isDescriptionExpandedStream =
//       StreamController<bool>.broadcast();
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final settings = Provider.of<SettingsBloc>(context).currentSettings;
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
//       child: Text(widget.season.title ?? 'Extra', style: textTheme.titleLarge),
//     );
//   }
// }
//
// class FollowButton extends StatelessWidget {
//   const FollowButton(this.podcast, {super.key});
//
//   final Podcast podcast;
//
//   @override
//   Widget build(BuildContext context) {
//     return Semantics(
//       liveRegion: true,
//       child: podcast.subscribed
//           ? OutlinedButton.icon(
//               style: OutlinedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               icon: const Icon(
//                 Icons.delete_outline,
//               ),
//               label: Text(L.of(context)!.unsubscribe_label),
//               onPressed: () {
//                 showPlatformDialog<void>(
//                   context: context,
//                   useRootNavigator: false,
//                   builder: (_) => BasicDialogAlert(
//                     title: Text(L.of(context)!.unsubscribe_label),
//                     content: Text(L.of(context)!.unsubscribe_message),
//                     actions: <Widget>[
//                       BasicDialogAction(
//                         title: ExcludeSemantics(
//                           child: ActionText(
//                             L.of(context)!.cancel_button_label,
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                       BasicDialogAction(
//                         title: ExcludeSemantics(
//                           child: ActionText(
//                             L.of(context)!.unsubscribe_button_label,
//                           ),
//                         ),
//                         iosIsDefaultAction: true,
//                         iosIsDestructiveAction: true,
//                         onPressed: () {
//                           // bloc.podcastEvent(PodcastEvent.unsubscribe);
//
//                           Navigator.pop(context);
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//           : OutlinedButton.icon(
//               style: OutlinedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               icon: const Icon(
//                 Icons.add,
//               ),
//               label: Text(L.of(context)!.subscribe_label),
//               onPressed: () {
//                 // bloc.podcastEvent(PodcastEvent.subscribe);
//               },
//             ),
//     );
//   }
// }
//
// class SeasonSwitch extends StatelessWidget {
//   const SeasonSwitch({required this.isOn, super.key});
//
//   final bool isOn;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const Text('Season'),
//         Switch(
//           value: isOn,
//           onChanged: (isOn) {
//             final podcastBloc =
//                 Provider.of<PodcastBloc>(context, listen: false);
//             podcastBloc.toggleSeasonView();
//           },
//         ),
//       ],
//     );
//   }
// }
