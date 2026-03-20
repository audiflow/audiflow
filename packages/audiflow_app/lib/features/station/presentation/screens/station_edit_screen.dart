import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Station' : 'New Station'),
        actions: [
          if (editState.isSaving)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator.adaptive(),
            )
          else
            TextButton(
              onPressed: () => _onSave(controller),
              child: const Text('Save'),
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
        Text('Station Name', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: Spacing.xs),
        TextField(
          controller: _nameController,
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Morning Commute',
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
        Text('Podcasts', style: theme.textTheme.titleSmall),
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
        Text('Playback State', style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.xs),
        ...StationPlaybackState.values.map(
          (value) => RadioListTile<StationPlaybackState>(
            value: value,
            groupValue: state.playbackState,
            onChanged: (v) {
              if (v != null) controller.setPlaybackState(v);
            },
            title: Text(_playbackStateLabel(value)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  String _playbackStateLabel(StationPlaybackState value) => switch (value) {
    StationPlaybackState.all => 'All episodes',
    StationPlaybackState.unplayed => 'Unplayed only',
    StationPlaybackState.inProgress => 'In progress only',
  };

  Widget _buildAttributeFilters(
    StationEditState state,
    StationEditController controller,
  ) {
    return Column(
      children: [
        SwitchListTile(
          value: state.filterDownloaded,
          onChanged: controller.setFilterDownloaded,
          title: const Text('Downloaded only'),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          value: state.filterFavorited,
          onChanged: controller.setFilterFavorited,
          title: const Text('Favorited only'),
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
            Text('Duration Filter', style: theme.textTheme.titleSmall),
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
                items: const [
                  DropdownMenuItem(
                    value: 'shorterThan',
                    child: Text('Shorter than'),
                  ),
                  DropdownMenuItem(
                    value: 'longerThan',
                    child: Text('Longer than'),
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
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: TextEditingController(
                    text: filter.durationMinutes.toString(),
                  ),
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
        Text('Published Within', style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.xs),
        DropdownButtonFormField<int?>(
          value: state.publishedWithinDays,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: options
              .map(
                (days) => DropdownMenuItem<int?>(
                  value: days,
                  child: Text(days == null ? 'No limit' : 'Last $days days'),
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
        Text('Episode Order', style: theme.textTheme.titleSmall),
        const SizedBox(height: Spacing.xs),
        SegmentedButton<StationEpisodeSort>(
          segments: const [
            ButtonSegment(
              value: StationEpisodeSort.newest,
              label: Text('Newest first'),
            ),
            ButtonSegment(
              value: StationEpisodeSort.oldest,
              label: Text('Oldest first'),
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
        label: const Text('Delete Station'),
        onPressed: () => _onDelete(context, controller),
      ),
    );
  }

  Future<void> _onDelete(
    BuildContext context,
    StationEditController controller,
  ) async {
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Station'),
        content: const Text(
          'Are you sure you want to delete this station? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
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
