import 'package:audiflow/common/ui/error_notifier.dart';
import 'package:audiflow/common/ui/fill_remaining_error.dart';
import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/features/browser/chart/ui/podcast_chart_controller.dart';
import 'package:audiflow/features/browser/common/ui/basic_app_bar.dart';
import 'package:audiflow/features/browser/common/ui/chart_item_list.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class PodcastChartPage extends HookConsumerWidget {
  const PodcastChartPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastChartControllerProvider);
    final controller = useScrollController();

    return ScrollsToTop(
      onScrollsToTop: (event) async {
        await controller.animateTo(
          event.to,
          duration: event.duration,
          curve: event.curve,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                BasicAppBar(title: L10n.of(context).browse),
                // Podcast in chart
                if (state.isLoading)
                  const FillRemainingLoading()
                else if (state.hasError)
                  FillRemainingError.podcastNoResults()
                else ...[
                  SliverToBoxAdapter(
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          onSelect: (country) {
                            ref
                                .read(podcastChartControllerProvider.notifier)
                                .setCountry(country.countryCode);
                          },
                          favorite: state.value!.chartCountries
                              .map((country) => country.code)
                              .toList(),
                          useSafeArea: true,
                          useRootNavigator: true,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                          left: 14,
                        ),
                        child: Text(
                          L10n.of(context).popularPodcastsIn(
                            CountryService()
                                    .findByCode(state.value!.chartCountry.code)
                                    ?.flagEmoji ??
                                '',
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 30),
                    sliver: ITunesItemList(items: state.value!.chartItems),
                  ),
                ],
              ],
            ),
            const ErrorNotifier(),
          ],
        ),
      ),
    );
  }
}
