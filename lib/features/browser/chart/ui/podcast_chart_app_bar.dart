import 'package:audiflow/features/browser/chart/ui/podcast_chart_controller.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PodcastChartAppBar extends ConsumerWidget {
  const PodcastChartAppBar({
    super.key,
    this.elevation = 0,
  });

  final double? elevation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastChartControllerProvider);
    return SliverAppBar(
      pinned: true,
      expandedHeight: 100,
      elevation: elevation,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          L10n.of(context).browse,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (_) {
            showCountryPicker(
              context: context,
              onSelect: (country) {
                ref
                    .read(podcastChartControllerProvider.notifier)
                    .setCountry(country.countryCode);
              },
              favorite:
                  state.requireValue.chartCountries.map((e) => e.code).toList(),
            );
          },
          itemBuilder: (BuildContext context) {
            if (!state.hasValue) {
              return [];
            }

            final country = CountryService()
                .findByCode(state.requireValue.chartCountry.code);
            return [
              PopupMenuItem<String>(
                value: 'region',
                child: Row(
                  children: [
                    Text('${L10n.of(context).chartRegion}: '),
                    if (country != null)
                      Text('${country.flagEmoji}${country.name}'),
                  ],
                ),
              ),
            ];
          },
        ),
      ],
    );
  }
}
