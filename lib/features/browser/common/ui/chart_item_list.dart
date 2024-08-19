import 'package:audiflow/features/browser/common/model/itunes_item.dart';
import 'package:audiflow/features/browser/common/ui/chart_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ITunesItemList extends ConsumerWidget {
  const ITunesItemList({
    super.key,
    required this.items,
  });

  final List<ITunesItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return ITunesItemTile(itunesItem: items[index]);
        },
        childCount: items.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}
