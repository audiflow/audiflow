import 'package:audiflow_domain/audiflow_domain.dart'
    show PodcastViewMode, SmartPlaylist;
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Context-aware toggle for switching between Episodes and
/// Smart Playlist views.
///
/// - 0 playlists: renders nothing
/// - 1 playlist: segmented button [Episodes] / [PlaylistName]
/// - 2+ playlists: segmented button [Episodes] / [SelectedName v]
///   where tapping the playlist segment opens a dropdown menu
class SmartPlaylistViewToggle extends StatelessWidget {
  const SmartPlaylistViewToggle({
    super.key,
    required this.playlists,
    required this.selectedMode,
    required this.selectedPlaylistId,
    required this.onEpisodesSelected,
    required this.onPlaylistSelected,
  });

  final List<SmartPlaylist> playlists;
  final PodcastViewMode selectedMode;
  final String? selectedPlaylistId;
  final VoidCallback onEpisodesSelected;
  final ValueChanged<SmartPlaylist> onPlaylistSelected;

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) return const SizedBox.shrink();

    if (playlists.length == 1) {
      return _SinglePlaylistToggle(
        playlist: playlists.first,
        isPlaylist: selectedMode == PodcastViewMode.smartPlaylists,
        onEpisodesSelected: onEpisodesSelected,
        onPlaylistSelected: onPlaylistSelected,
      );
    }

    final selected =
        playlists.where((p) => p.id == selectedPlaylistId).firstOrNull ??
        playlists.first;

    return _MultiPlaylistToggle(
      playlists: playlists,
      selected: selected,
      isPlaylist: selectedMode == PodcastViewMode.smartPlaylists,
      onEpisodesSelected: onEpisodesSelected,
      onPlaylistSelected: onPlaylistSelected,
    );
  }
}

class _SinglePlaylistToggle extends StatelessWidget {
  const _SinglePlaylistToggle({
    required this.playlist,
    required this.isPlaylist,
    required this.onEpisodesSelected,
    required this.onPlaylistSelected,
  });

  final SmartPlaylist playlist;
  final bool isPlaylist;
  final VoidCallback onEpisodesSelected;
  final ValueChanged<SmartPlaylist> onPlaylistSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(value: false, label: Text(l10n.episodesLabel)),
        ButtonSegment(
          value: true,
          label: Text(playlist.displayName, overflow: TextOverflow.ellipsis),
        ),
      ],
      selected: {isPlaylist},
      onSelectionChanged: (selection) {
        if (selection.first) {
          onPlaylistSelected(playlist);
        } else {
          onEpisodesSelected();
        }
      },
      showSelectedIcon: false,
    );
  }
}

class _MultiPlaylistToggle extends StatelessWidget {
  const _MultiPlaylistToggle({
    required this.playlists,
    required this.selected,
    required this.isPlaylist,
    required this.onEpisodesSelected,
    required this.onPlaylistSelected,
  });

  final List<SmartPlaylist> playlists;
  final SmartPlaylist selected;
  final bool isPlaylist;
  final VoidCallback onEpisodesSelected;
  final ValueChanged<SmartPlaylist> onPlaylistSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Episodes segment style
    final episodesSelected = !isPlaylist;
    final playlistSelected = isPlaylist;

    return Row(
      children: [
        Expanded(
          child: _ToggleSegment(
            label: AppLocalizations.of(context).episodesLabel,
            isSelected: episodesSelected,
            isLeft: true,
            colorScheme: colorScheme,
            onTap: onEpisodesSelected,
          ),
        ),
        Expanded(
          child: _PlaylistSegment(
            label: selected.displayName,
            isSelected: playlistSelected,
            colorScheme: colorScheme,
            onSelect: () => onPlaylistSelected(selected),
            onDropdown: () => _showPlaylistMenu(context),
          ),
        ),
      ],
    );
  }

  void _showPlaylistMenu(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showMenu<SmartPlaylist>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx + size.width / 2,
        position.dy + size.height,
        position.dx + size.width,
        position.dy + size.height + 200,
      ),
      items: playlists.map((playlist) {
        final isCurrent = playlist.id == selected.id;
        return PopupMenuItem<SmartPlaylist>(
          value: playlist,
          child: Text(
            playlist.displayName,
            style: isCurrent
                ? TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
        );
      }).toList(),
    ).then((chosen) {
      if (chosen != null) {
        onPlaylistSelected(chosen);
      }
    });
  }
}

/// A single segment in the custom toggle row.
class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.label,
    required this.isSelected,
    required this.isLeft,
    required this.colorScheme,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isLeft;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(20) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(20),
        ),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(20) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(20),
        ),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Right segment split into selector (label) + dropdown arrow.
///
/// Tapping the label selects the current playlist.
/// Tapping the arrow opens the playlist menu.
class _PlaylistSegment extends StatelessWidget {
  const _PlaylistSegment({
    required this.label,
    required this.isSelected,
    required this.colorScheme,
    required this.onSelect,
    required this.onDropdown,
  });

  final String label;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onSelect;
  final VoidCallback onDropdown;

  @override
  Widget build(BuildContext context) {
    final fgColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;
    final bgColor = isSelected
        ? colorScheme.secondaryContainer
        : Colors.transparent;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelect,
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
            InkWell(
              onTap: onDropdown,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_drop_down, size: 20, color: fgColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
