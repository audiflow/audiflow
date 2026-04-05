import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../library/presentation/controllers/library_controller.dart';

enum _PickerSort { nameAz, nameZa, recentlySubscribed, recentlyUpdated }

/// Fullscreen modal for selecting podcasts from subscriptions.
///
/// Returns the updated [Set<int>] of selected podcast IDs via [Navigator.pop],
/// or null when the user cancels.
class StationPodcastPickerScreen extends ConsumerStatefulWidget {
  const StationPodcastPickerScreen({required this.selectedIds, super.key});

  /// Currently selected podcast IDs.
  final Set<int> selectedIds;

  @override
  ConsumerState<StationPodcastPickerScreen> createState() =>
      _StationPodcastPickerScreenState();
}

class _StationPodcastPickerScreenState
    extends ConsumerState<StationPodcastPickerScreen> {
  late Set<int> _selected;
  String _searchQuery = '';
  _PickerSort _sort = _PickerSort.nameAz;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.from(widget.selectedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Subscription> _sortedSubscriptions(List<Subscription> subs) {
    final query = _searchQuery.toLowerCase();
    final filtered = subs
        .where((s) => !s.isCached)
        .where((s) => query.isEmpty || s.title.toLowerCase().contains(query))
        .toList();

    filtered.sort(
      (a, b) => switch (_sort) {
        _PickerSort.nameAz => a.title.compareTo(b.title),
        _PickerSort.nameZa => b.title.compareTo(a.title),
        _PickerSort.recentlySubscribed => b.subscribedAt.compareTo(
          a.subscribedAt,
        ),
        _PickerSort.recentlyUpdated => _compareByLastRefreshed(a, b),
      },
    );

    return filtered;
  }

  int _compareByLastRefreshed(Subscription a, Subscription b) {
    final aDate = a.lastRefreshedAt;
    final bDate = b.lastRefreshedAt;
    if (aDate != null && bDate != null) return bDate.compareTo(aDate);
    if (aDate != null) return -1;
    if (bDate != null) return 1;
    return b.subscribedAt.compareTo(a.subscribedAt);
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected = Set<int>.from(_selected)..remove(id);
      } else {
        _selected = Set<int>.from(_selected)..add(id);
      }
    });
  }

  Future<void> _showSortSheet(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(l10n.stationPickerSortNameAz),
            trailing: _sort == _PickerSort.nameAz
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              setState(() => _sort = _PickerSort.nameAz);
              Navigator.of(ctx).pop();
            },
          ),
          ListTile(
            title: Text(l10n.stationPickerSortNameZa),
            trailing: _sort == _PickerSort.nameZa
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              setState(() => _sort = _PickerSort.nameZa);
              Navigator.of(ctx).pop();
            },
          ),
          ListTile(
            title: Text(l10n.stationPickerSortRecentlySubscribed),
            trailing: _sort == _PickerSort.recentlySubscribed
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              setState(() => _sort = _PickerSort.recentlySubscribed);
              Navigator.of(ctx).pop();
            },
          ),
          ListTile(
            title: Text(l10n.stationPickerSortRecentlyUpdated),
            trailing: _sort == _PickerSort.recentlyUpdated
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              setState(() => _sort = _PickerSort.recentlyUpdated);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subscriptionsAsync = ref.watch(librarySubscriptionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        title: Text(l10n.stationPickerTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: Text(
              l10n.commonDone,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) => _buildContent(context, l10n, subscriptions),
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<Subscription> subscriptions,
  ) {
    final sorted = _sortedSubscriptions(subscriptions);
    final nonCachedCount = subscriptions.where((s) => !s.isCached).length;
    final countLabel = _searchQuery.isEmpty
        ? l10n.stationPickerSubscribed(nonCachedCount)
        : l10n.stationPickerResults(sorted.length);

    return Column(
      children: [
        _SearchBar(
          controller: _searchController,
          hintText: l10n.stationPickerSearch,
          onChanged: (query) => setState(() => _searchQuery = query),
        ),
        _SortBar(countLabel: countLabel, onSortTap: () => _showSortSheet(l10n)),
        Expanded(
          child: ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final sub = sorted[index];
              final isSelected = _selected.contains(sub.id);
              return _PickerRow(
                key: ValueKey(sub.id),
                subscription: sub,
                isSelected: isSelected,
                onTap: () => _toggleSelection(sub.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({required this.countLabel, required this.onSortTap});

  final String countLabel;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            countLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: onSortTap,
            color: colorScheme.onSurfaceVariant,
            iconSize: 20,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.subscription,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Subscription subscription;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            _Checkbox(isSelected: isSelected, colorScheme: colorScheme),
            const SizedBox(width: Spacing.sm),
            _Artwork(
              artworkUrl: subscription.artworkUrl,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                subscription.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.isSelected, required this.colorScheme});

  final bool isSelected;
  final ColorScheme colorScheme;

  static const double _size = 24.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colorScheme.primary : Colors.transparent,
        border: isSelected
            ? null
            : Border.all(color: colorScheme.outline, width: 1.5),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.artworkUrl, required this.colorScheme});

  final String? artworkUrl;
  final ColorScheme colorScheme;

  static const double _size = 48.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: SizedBox(
        width: _size,
        height: _size,
        child: artworkUrl != null
            ? Image.network(
                artworkUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.podcasts,
        size: 24,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
