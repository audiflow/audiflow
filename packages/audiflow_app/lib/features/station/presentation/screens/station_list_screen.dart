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
    final stations = ref.watch(stationListProvider).value ?? const [];
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
      body: CustomScrollView(
        slivers: [
          StationGridSliver(stations: stations),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
        ],
      ),
    );
  }
}
