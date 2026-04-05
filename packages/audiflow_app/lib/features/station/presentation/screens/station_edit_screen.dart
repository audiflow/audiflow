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
import 'station_podcast_picker_screen.dart';

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
  late TextEditingController _minutesController;
  final FocusNode _nameFocusNode = FocusNode();
  bool _nameInitialized = false;
  bool _isReorderMode = false;
  int? _expandedPodcastId;

  /// Whether the initial auto-focus has been consumed.
  /// After this, only user taps may focus the name field.
  bool _autoFocusConsumed = false;

  /// Set to true by TextField.onTap before the focus listener fires.
  bool _nameTappedByUser = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _minutesController = TextEditingController();
    _nameFocusNode.addListener(_guardNameFocus);
    if (widget.stationId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nameFocusNode.requestFocus();
      });
    } else {
      _autoFocusConsumed = true;
    }
  }

  void _guardNameFocus() {
    if (!_nameFocusNode.hasFocus) {
      if (!_autoFocusConsumed) _autoFocusConsumed = true;
      return;
    }
    // Focus gained — check if it's allowed.
    if (!_autoFocusConsumed) return; // initial auto-focus, allow
    if (_nameTappedByUser) {
      _nameTappedByUser = false;
      return; // user tapped, allow
    }
    // Unwanted focus restoration (e.g., modal dismiss) — reject.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _nameFocusNode.hasFocus) {
        _nameFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _nameFocusNode.removeListener(_guardNameFocus);
    _nameController.dispose();
    _minutesController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  String _resolveError(AppLocalizations l10n, String errorKey) {
    if (errorKey == StationEditError.nameRequired) {
      return l10n.stationNameRequired;
    }
    if (errorKey == StationEditError.podcastRequired) {
      return l10n.stationPodcastRequired;
    }
    if (errorKey == StationEditError.notFound) {
      return l10n.stationNotFoundTitle;
    }
    if (StationEditError.isLimitReached(errorKey)) {
      return l10n.stationLimitReached(StationEditError.parseLimitMax(errorKey));
    }
    return errorKey;
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
              _ErrorBanner(message: _resolveError(l10n, editState.error!)),
            _buildNameField(controller),
            const SizedBox(height: Spacing.lg),
            _buildAttributeFilters(editState, controller),
            const SizedBox(height: Spacing.sm),
            _buildEpisodeLimitRow(editState, controller),
            _buildDurationFilter(context, editState, controller),
            _buildGroupByPodcast(editState, controller),
            _buildSortOrder(context, editState, controller),
            const SizedBox(height: Spacing.lg),
            _buildPodcastsSection(context, editState, controller),
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

  String _episodeLimitLabel(AppLocalizations l10n, int count) =>
      count == 1 ? l10n.stationLatestOnly : l10n.stationLatestN(count);

  Future<void> _onSave(StationEditController controller) async {
    controller.setName(_nameController.text);
    final saved = await controller.save();
    if (!mounted) return;
    if (saved != null) {
      context.pop();
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
          focusNode: _nameFocusNode,
          onTap: () => _nameTappedByUser = true,
          maxLength: 50,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).stationNameHint,
            border: const OutlineInputBorder(),
          ),
          onChanged: controller.setName,
        ),
      ],
    );
  }

  Widget _buildEpisodeLimitRow(
    StationEditState state,
    StationEditController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final limit = state.defaultEpisodeLimit;
    final label = limit == null
        ? l10n.stationAllEpisodes
        : _episodeLimitLabel(l10n, limit);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.stationEpisodes),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _showEpisodeLimitPicker(state, controller),
    );
  }

  void _showEpisodeLimitPicker(
    StationEditState state,
    StationEditController controller,
  ) {
    const options = [1, 2, 3, 4, 5, 10, null]; // null = All
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: options.map((opt) {
            final label = opt == null
                ? l10n.stationAllEpisodes
                : _episodeLimitLabel(l10n, opt);
            final isSelected = state.defaultEpisodeLimit == opt;
            return ListTile(
              title: Text(label),
              trailing: isSelected
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () {
                controller.setDefaultEpisodeLimit(opt);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAttributeFilters(
    StationEditState state,
    StationEditController controller,
  ) {
    return Column(
      children: [
        SwitchListTile(
          value: state.hideCompleted,
          onChanged: controller.setHideCompleted,
          title: Text(
            AppLocalizations.of(context).stationFilterHideCompletedLabel,
          ),
          contentPadding: EdgeInsets.zero,
        ),
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

    // Sync minutes controller when filter changes externally.
    if (filter != null &&
        _minutesController.text != filter.durationMinutes.toString()) {
      _minutesController.text = filter.durationMinutes.toString();
    }

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
                  _minutesController.text = '30';
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
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    suffixText: 'min',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onTap: () => _minutesController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _minutesController.text.length,
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

  Widget _buildGroupByPodcast(
    StationEditState state,
    StationEditController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SwitchListTile(
          value: state.groupByPodcast,
          onChanged: controller.setGroupByPodcast,
          title: Text(l10n.stationGroupByPodcast),
          contentPadding: EdgeInsets.zero,
        ),
        if (state.groupByPodcast) _buildPodcastOrderSelector(state, controller),
      ],
    );
  }

  Widget _buildPodcastOrderSelector(
    StationEditState state,
    StationEditController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final sortLabel = switch (state.podcastSort) {
      StationPodcastSort.subscribeAsc => l10n.stationPodcastSortSubscribeOld,
      StationPodcastSort.subscribeDesc => l10n.stationPodcastSortSubscribeNew,
      StationPodcastSort.nameAsc => l10n.stationPodcastSortNameAz,
      StationPodcastSort.nameDesc => l10n.stationPodcastSortNameZa,
      StationPodcastSort.manual => l10n.stationPodcastSortManual,
    };

    return ListTile(
      contentPadding: const EdgeInsets.only(left: Spacing.lg),
      title: Text(l10n.stationPodcastOrder),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sortLabel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () => _showPodcastSortSheet(state, controller),
    );
  }

  Widget _buildPodcastsSection(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
  ) {
    final subscriptionsAsync = ref.watch(librarySubscriptionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPodcastsSectionHeader(context, state, controller),
        const SizedBox(height: Spacing.xs),
        _buildSelectPodcastsRow(context, state, controller, subscriptionsAsync),
        ..._buildSelectedPodcastList(
          context,
          state,
          controller,
          subscriptionsAsync,
        ),
      ],
    );
  }

  Widget _buildPodcastsSectionHeader(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final isManual = state.podcastSort == StationPodcastSort.manual;
    final sortLabel = _isReorderMode
        ? l10n.stationReorderDone
        : l10n.stationReorder;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.stationPodcasts.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        if (isManual)
          TextButton(
            onPressed: _onPodcastSortButtonTap,
            child: Text(sortLabel),
          ),
      ],
    );
  }

  void _onPodcastSortButtonTap() {
    if (_isReorderMode) {
      // "Done" exits reorder mode without opening the sort picker.
      setState(() => _isReorderMode = false);
      return;
    }
    // Button is only rendered in manual mode — enter reorder mode.
    setState(() => _isReorderMode = true);
  }

  void _showPodcastSortSheet(
    StationEditState state,
    StationEditController controller,
  ) {
    final l10n = AppLocalizations.of(context);
    final options = [
      (StationPodcastSort.subscribeAsc, l10n.stationPodcastSortSubscribeOld),
      (StationPodcastSort.subscribeDesc, l10n.stationPodcastSortSubscribeNew),
      (StationPodcastSort.nameAsc, l10n.stationPodcastSortNameAz),
      (StationPodcastSort.nameDesc, l10n.stationPodcastSortNameZa),
      (StationPodcastSort.manual, l10n.stationPodcastSortManual),
    ];
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((entry) {
            final (sort, label) = entry;
            final isSelected = state.podcastSort == sort;
            return ListTile(
              title: Text(label),
              trailing: isSelected
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () {
                controller.setPodcastSort(sort);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSelectPodcastsRow(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
    AsyncValue<List<Subscription>> subscriptionsAsync,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final totalSubscribed =
        subscriptionsAsync.whenOrNull(
          data: (subs) => subs.where((s) => !s.isCached).length,
        ) ??
        0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        l10n.stationSelectPodcasts,
        style: TextStyle(color: theme.colorScheme.primary),
      ),
      trailing: Text(
        l10n.stationSelectPodcastsCount(
          state.selectedPodcastIds.length,
          totalSubscribed,
        ),
      ),
      onTap: () async {
        final result = await Navigator.push<Set<int>>(
          context,
          MaterialPageRoute<Set<int>>(
            fullscreenDialog: true,
            builder: (_) => StationPodcastPickerScreen(
              selectedIds: state.selectedPodcastIds,
            ),
          ),
        );
        if (result != null) await controller.updateSelectedPodcasts(result);
      },
    );
  }

  List<Widget> _buildSelectedPodcastList(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
    AsyncValue<List<Subscription>> subscriptionsAsync,
  ) {
    final subscriptions = subscriptionsAsync.value;
    if (subscriptions == null) return [];

    final subMap = {for (final s in subscriptions) s.id: s};
    final orderedIds = state.podcastSortOrder
        .where(state.selectedPodcastIds.contains)
        .toList();

    if (_isReorderMode) {
      return [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            final updated = List<int>.from(orderedIds);
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = updated.removeAt(oldIndex);
            updated.insert(newIndex, item);
            // Rebuild full sort order with remaining non-selected ids preserved.
            final nonSelected = state.podcastSortOrder
                .where((id) => !state.selectedPodcastIds.contains(id))
                .toList();
            controller.reorderPodcasts([...updated, ...nonSelected]);
          },
          children: orderedIds.map((id) {
            final sub = subMap[id];
            return ListTile(
              key: ValueKey(id),
              leading: _buildPodcastArtwork(context, sub?.artworkUrl),
              title: Text(
                sub?.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.drag_handle),
            );
          }).toList(),
        ),
      ];
    }

    return orderedIds.map((id) {
      final sub = subMap[id];
      return _buildPodcastRow(context, state, controller, id, sub);
    }).toList();
  }

  Widget _buildPodcastRow(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
    int podcastId,
    Subscription? sub,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isExpanded = _expandedPodcastId == podcastId;
    final perPodcastLimit = state.podcastEpisodeLimits[podcastId];
    // null = use default; allEpisodesSentinel (0) = explicit "all episodes"
    final effectiveLimit = perPodcastLimit == allEpisodesSentinel
        ? null
        : (perPodcastLimit ?? state.defaultEpisodeLimit);
    final limitLabel = effectiveLimit == null
        ? l10n.stationAllEpisodes
        : _episodeLimitLabel(l10n, effectiveLimit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: _buildPodcastArtwork(context, sub?.artworkUrl),
          title: Text(
            sub?.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                limitLabel,
                style: TextStyle(
                  color: isExpanded
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: isExpanded
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          onTap: () {
            setState(() => _expandedPodcastId = isExpanded ? null : podcastId);
          },
        ),
        if (isExpanded)
          _buildPerPodcastLimitChips(context, state, controller, podcastId),
      ],
    );
  }

  Widget _buildPerPodcastLimitChips(
    BuildContext context,
    StationEditState state,
    StationEditController controller,
    int podcastId,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    const options = <int?>[1, 2, 3, 4, 5, 10, null]; // null = All
    final defaultLimit = state.defaultEpisodeLimit;
    final defaultLabel = defaultLimit == null
        ? l10n.stationDefaultAll
        : l10n.stationDefault(_episodeLimitLabel(l10n, defaultLimit));

    return Padding(
      padding: const EdgeInsets.only(left: Spacing.lg, bottom: Spacing.sm),
      child: Wrap(
        spacing: Spacing.xs,
        children: [
          // "Default(N)" chip — selected when no override is set.
          ChoiceChip(
            label: Text(defaultLabel),
            selected: !state.podcastEpisodeLimits.containsKey(podcastId),
            onSelected: (_) {
              controller.setPodcastEpisodeLimit(podcastId, null);
              // Remove override (null removes from map in controller).
            },
          ),
          ...options.map((opt) {
            final label = opt == null
                ? l10n.stationAllEpisodes
                : _episodeLimitLabel(l10n, opt);
            // For "All" chip (opt == null), selected when sentinel is stored.
            // For numeric chips, selected when map contains exact value.
            final isSelected = opt == null
                ? state.podcastEpisodeLimits[podcastId] == allEpisodesSentinel
                : (state.podcastEpisodeLimits.containsKey(podcastId) &&
                      state.podcastEpisodeLimits[podcastId] == opt);
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: theme.colorScheme.primaryContainer,
              onSelected: (_) {
                if (opt == null) {
                  _setAllEpisodesOverride(controller, podcastId);
                } else {
                  controller.setPodcastEpisodeLimit(podcastId, opt);
                }
              },
            );
          }),
        ],
      ),
    );
  }

  void _setAllEpisodesOverride(
    StationEditController controller,
    int podcastId,
  ) {
    // Store the sentinel value (0) to distinguish "explicitly all episodes"
    // from "use station default" (null / absent from map).
    controller.setPodcastEpisodeLimit(podcastId, allEpisodesSentinel);
  }

  Widget _buildPodcastArtwork(BuildContext context, String? artworkUrl) {
    final colorScheme = Theme.of(context).colorScheme;
    const size = 40.0;

    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: SizedBox(
        width: size,
        height: size,
        child: artworkUrl != null
            ? Image.network(
                artworkUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _artworkPlaceholder(colorScheme),
              )
            : _artworkPlaceholder(colorScheme),
      ),
    );
  }

  Widget _artworkPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.podcasts,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
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
