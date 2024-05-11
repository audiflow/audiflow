import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:flutter/material.dart';

class FillRemainingError extends StatelessWidget {
  const FillRemainingError({
    required this.icon,
    required this.messageBuilder,
    super.key,
  });

  FillRemainingError.podcastNoResults({Key? key})
      : this(
          icon: Icons.search,
          messageBuilder: (context) =>
              L10n.of(context)!.no_search_results_message,
          key: key,
        );

  FillRemainingError.episode({Key? key})
      : this(
          icon: Icons.search,
          messageBuilder: (context) =>
              L10n.of(context)!.no_search_results_message,
          key: key,
        );

  final IconData icon;
  final String Function(BuildContext context) messageBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 75,
              color: Theme.of(context).primaryColor,
            ),
            Text(
              messageBuilder(context),
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
