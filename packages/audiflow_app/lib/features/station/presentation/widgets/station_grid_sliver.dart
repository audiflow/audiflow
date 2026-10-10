import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import 'station_grid_tile.dart';

/// [stations] as a grid of [StationGridTile]s, each opening its
/// station (redesign 4.1). Two columns on a phone, more as the width grows,
/// so a tablet tile stays phone-sized. Shared by the Library section and
/// the full station list.
class StationGridSliver extends StatelessWidget {
  const StationGridSliver({required this.stations, super.key});

  final List<Station> stations;

  static const double _gridGap = 12;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final columnCount = ResponsiveGrid.columnCount(
          availableWidth:
              constraints.crossAxisExtent - 2 * Spacing.screenHorizontal,
          itemWidth: LayoutConstants.stationGridItemWidth,
        );
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screenHorizontal,
            Spacing.xs,
            Spacing.screenHorizontal,
            0,
          ),
          sliver: SliverList.separated(
            itemCount: (stations.length + columnCount - 1) ~/ columnCount,
            separatorBuilder: (_, _) => const SizedBox(height: _gridGap),
            itemBuilder: (context, row) => _row(
              context,
              stations.skip(row * columnCount).take(columnCount).toList(),
              columnCount,
            ),
          ),
        );
      },
    );
  }

  // Rows instead of a SliverGrid so each tile sizes to its content and
  // large text never overflows a fixed aspect ratio.
  Widget _row(BuildContext context, List<Station> stationsInRow, int columns) {
    Widget cell(int column) {
      if (stationsInRow.length <= column) return const SizedBox();
      final station = stationsInRow[column];
      return StationGridTile(
        key: ValueKey(station.id),
        station: station,
        onTap: () => context.push('${AppRoutes.library}/station/${station.id}'),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var column = 0; column < columns; column++) ...[
          if (0 < column) const SizedBox(width: _gridGap),
          Expanded(child: cell(column)),
        ],
      ],
    );
  }
}
