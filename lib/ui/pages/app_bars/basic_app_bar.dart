import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BasicAppBar extends HookConsumerWidget {
  const BasicAppBar({
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
      expandedHeight: 100,
      elevation: elevation,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 20),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (_) {
            ref.read(routerProvider).router.pushNamed('settings');
          },
          itemBuilder: (BuildContext context) {
            return ['settings'].map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(L10n.of(context).settings),
              );
            }).toList();
          },
        ),
      ],
    );
  }
}
