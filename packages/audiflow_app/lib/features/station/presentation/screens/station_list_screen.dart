import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/station_list_controller.dart';
import '../widgets/station_grid_sliver.dart';

/// Every station, in the user's order, behind the Library section's
/// "Show all" link (the section itself shows at most four).
class StationListScreen extends ConsumerWidget {
  const StationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stationsAsync = ref.watch(stationListProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.stationSectionTitle),
        actions: [
          IconButton(
            tooltip: l10n.stationAdd,
            icon: Icon(Icons.add_rounded, color: AppColors.of(context).accent),
            onPressed: () => context.push(AppRoutes.stationNew),
          ),
        ],
      ),
      body: stationsAsync.when(
        data: (stations) => stations.isEmpty
            ? _Message(text: l10n.stationNoStationsYet)
            : CustomScrollView(
                slivers: [
                  StationGridSliver(stations: stations),
                  const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _Message(
          text: l10n.stationListLoadError,
          action: TextButton(
            onPressed: () => ref.invalidate(stationListProvider),
            child: Text(l10n.commonRetry),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.of(context).inkSecondary,
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}
