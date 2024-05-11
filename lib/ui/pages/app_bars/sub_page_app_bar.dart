import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubPageAppBar extends HookConsumerWidget {
  const SubPageAppBar({
    super.key,
    required this.title,
    this.elevation = 0,
  });

  final String title;
  final double? elevation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      elevation: elevation,
      title: Text(title),
    );
  }
}
