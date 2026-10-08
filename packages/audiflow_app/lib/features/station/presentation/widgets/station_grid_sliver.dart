import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import 'station_grid_tile.dart';

/// [stations] as a two-column grid of [StationGridTile]s, each opening its
/// station (redesign 4.1). Shared by the Library section and the full
/// station list.
class StationGridSliver extends StatelessWidget {
  const StationGridSliver({required this.stations, super.key});

  final List<Station> stations;

  static const double _gridGap = 12;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        Spacing.xs,
        Spacing.screenHorizontal,
        0,
      ),
      sliver: SliverList.separated(
        itemCount: (stations.length + 1) ~/ 2,
        separatorBuilder: (_, _) => const SizedBox(height: _gridGap),
        itemBuilder: (context, row) =>
            _row(context, stations.skip(row * 2).take(2).toList()),
      ),
    );
  }

  // Rows of two instead of a SliverGrid so each tile sizes to its content
  // and large text never overflows a fixed aspect ratio.
  Widget _row(BuildContext context, List<Station> pair) {
    Widget tile(Station station) => StationGridTile(
      key: ValueKey(station.id),
      station: station,
      onTap: () => context.push('${AppRoutes.library}/station/${station.id}'),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: tile(pair.first)),
        const SizedBox(width: _gridGap),
        Expanded(child: 1 < pair.length ? tile(pair[1]) : const SizedBox()),
      ],
    );
  }
}
