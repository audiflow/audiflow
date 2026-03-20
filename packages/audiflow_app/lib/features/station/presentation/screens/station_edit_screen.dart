import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../library/presentation/controllers/library_controller.dart';
import '../controllers/station_edit_controller.dart';

/// Screen for creating or editing a [Station].
///
/// When [stationId] is null, the screen operates in create mode.
/// When [stationId] is provided, the screen loads and edits the existing station.
class StationEditScreen extends ConsumerStatefulWidget {
  const StationEditScreen({this.stationId, super.key});

  final int? stationId;

  @override
  ConsumerState<StationEditScreen> createState() => _StationEditScreenState();
}

class _StationEditScreenState extends ConsumerState<StationEditScreen> {
  late TextEditingController _nameController;
  bool _nameInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(
      stationEditControllerProvider(widget.stationId),
    );
    final controller = ref.read(
      stationEditControllerProvider(widget.stationId).notifier,
    );

    // Sync name field once when state is loaded.
    if (!_nameInitialized && editState.name.isNotEmpty) {
      _nameController.text = editState.name;
      _nameController.selection = TextSelection.collapsed(
        offset: editState.name.length,
      );
      _nameInitialized = true;
    }

    final isEditMode = widget.stationId != null;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? l10n.stationEditTitle : l10n.stationNew),
        actions: [
          if (editState.isSaving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator.adaptive(),
            )
          else
            TextButton(
              onPressed: () => _onSave(controller),
              child: Text(l10n.stationSave),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editState.error != null)
              _ErrorBanner(message: editState.error!),
            _buildNameField(controller),
            const SizedBox(height: Spacing.lg),
            _buildPodcastPicker(context, editState, controller),
            const SizedBox(height: Spacing.lg),
            _buildPlaybackStateSection(context, editState, controller),
            const SizedBox(height: Spacing.lg),
            _buildAttributeFilters(editState, controller),
            const SizedBox(height: Spacing.lg),
            _buildDurationFilter(context, editState, controller),
            const SizedBox(height: Spacing.lg),
            _buildPublishedWithin(context, editState, controller),
            const SizedBox(height: Spacing.lg),
            _buildSortOrder(context, editState, controller),
            if (isEditMode) ...[
              const SizedBox(height: Spacing.xl),
              _buildDeleteButton(context, controller),
            ],
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave(StationEditController controller) async {
    controller.setName(_nameController.text);
    final saved = await controller.save();
    if (!mounted) return;
    if (saved != null) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildNameField(StationEditController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).stationName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        TextField(
          controller: _nameController,
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g., News, Tech, Comedy',
            border: OutlineInputBorder(),
          ),
          onChanged: controller.setName,
        ),
      ],
    );
  }

  Widget _buildPodcastPicker(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
  ) {
    final subscriptionsAsync = ref.watch(librarySubscriptionsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).stationPodcasts,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        subscriptionsAsync.when(
          data: (subscriptions) {
            final actual = subscriptions.where((s) => !s.isCached).toList();
            if (actual.isEmpty) {
              return Text(
                'No subscriptions yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Card(
              child: Column(
                children: actual
                    .map(
                      (sub) => CheckboxListTile(
                        key: ValueKey(sub.id),
                        value: state.selectedPodcastIds.contains(sub.id),
                        onChanged: (_) => controller.togglePodcast(sub.id),
                        title: Text(
                          sub.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          sub.artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          },
          loading: () => const CircularProgressIndicator.adaptive(),
          error: (_, _) => const Text('Failed to load subscriptions'),
        ),
      ],
    );
  }

  Widget _buildPlaybackStateSection(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).stationPlaybackState,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        RadioGroup<StationPlaybackState>(
          groupValue: state.playbackState,
          onChanged: (v) {
            if (v != null) controller.setPlaybackState(v);
          },
          child: Column(
            children: StationPlaybackState.values
                .map(
                  (value) => RadioListTile<StationPlaybackState>(
                    value: value,
                    title: Text(_playbackStateLabel(value)),
                    contentPadding: EdgeInsets.zero,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  String _playbackStateLabel(StationPlaybackState value) {
    final l10n = AppLocalizations.of(context);
    return switch (value) {
      StationPlaybackState.all => l10n.stationFilterAllLabel,
      StationPlaybackState.unplayed => l10n.stationFilterUnplayedLabel,
      StationPlaybackState.inProgress => l10n.stationFilterInProgressLabel,
    };
  }

  Widget _buildAttributeFilters(
    StationEditState state,
    StationEditController controller,
  ) {
    return Column(
      children: [
        SwitchListTile(
          value: state.filterDownloaded,
          onChanged: controller.setFilterDownloaded,
          title: Text(
            AppLocalizations.of(context).stationFilterDownloadedLabel,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: state.filterFavorited,
          onChanged: controller.setFilterFavorited,
          title: Text(AppLocalizations.of(context).stationFilterFavoritedLabel),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildDurationFilter(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
  ) {
    final theme = Theme.of(context);
    final filter = state.durationFilter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).stationDurationFilter,
              style: theme.textTheme.titleSmall,
            ),
            Switch(
              value: filter != null,
              onChanged: (enabled) {
                if (enabled) {
                  final defaultFilter = StationDurationFilter()
                    ..durationOperator = 'shorterThan'
                    ..durationMinutes = 30;
                  controller.setDurationFilter(defaultFilter);
                } else {
                  controller.setDurationFilter(null);
                }
              },
            ),
          ],
        ),
        if (filter != null) ...[
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              DropdownButton<String>(
                value: filter.durationOperator,
                items: [
                  DropdownMenuItem(
                    value: 'shorterThan',
                    child: Text(
                      AppLocalizations.of(context).stationShorterThan,
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'longerThan',
                    child: Text(AppLocalizations.of(context).stationLongerThan),
                  ),
                ],
                onChanged: (op) {
                  if (op == null) return;
                  final updated = StationDurationFilter()
                    ..durationOperator = op
                    ..durationMinutes = filter.durationMinutes;
                  controller.setDurationFilter(updated);
                },
              ),
              const SizedBox(width: Spacing.sm),
              SizedBox(
                width: 80,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: filter.durationMinutes.toString(),
                  decoration: const InputDecoration(
                    suffixText: 'min',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    final minutes = int.tryParse(val);
                    if (minutes == null) return;
                    final updated = StationDurationFilter()
                      ..durationOperator = filter.durationOperator
                      ..durationMinutes = minutes;
                    controller.setDurationFilter(updated);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPublishedWithin(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
  ) {
    const options = [null, 7, 14, 30, 90];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).stationPublishedWithin,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        DropdownButtonFormField<int?>(
          initialValue: state.publishedWithinDays,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: options
              .map(
                (days) => DropdownMenuItem<int?>(
                  value: days,
                  child: Text(
                    days == null
                        ? AppLocalizations.of(context).stationNoLimit
                        : AppLocalizations.of(context).stationLastDays(days),
                  ),
                ),
              )
              .toList(),
          onChanged: controller.setPublishedWithinDays,
        ),
      ],
    );
  }

  Widget _buildSortOrder(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).stationEpisodeOrder,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        SegmentedButton<StationEpisodeSort>(
          segments: [
            ButtonSegment(
              value: StationEpisodeSort.newest,
              label: Text(AppLocalizations.of(context).stationNewestFirst),
            ),
            ButtonSegment(
              value: StationEpisodeSort.oldest,
              label: Text(AppLocalizations.of(context).stationOldestFirst),
            ),
          ],
          selected: {state.episodeSort},
          onSelectionChanged: (selection) {
            if (selection.isEmpty) return;
            controller.setEpisodeSort(selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    StationEditController controller,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        icon: const Icon(Icons.delete_outline),
        label: Text(AppLocalizations.of(context).stationDelete),
        onPressed: () => _onDelete(context, controller),
      ),
    );
  }

  Future<void> _onDelete(
    BuildContext context,
    StationEditController controller,
  ) async {
    final router = GoRouter.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.stationDeleteTitle),
        content: Text(l10n.stationDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleted = await controller.delete();
    if (!mounted) return;
    if (deleted) {
      // Pop both edit and detail screens back to library.
      router.go(AppRoutes.library);
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppBorders.md,
      ),
      child: Text(
        message,
        style: TextStyle(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
