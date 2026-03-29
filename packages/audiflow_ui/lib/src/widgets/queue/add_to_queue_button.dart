import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Button to add episode to queue.
///
/// - Tap: Play Later (add to end)
/// - Long press: Play Next (add to front)
class AddToQueueButton extends StatelessWidget {
  const AddToQueueButton({
    required this.onPlayLater,
    required this.onPlayNext,
    this.iconSize = 24,
    this.tooltip = 'Add to queue (long press for Play Next)',
    super.key,
  });

  final VoidCallback onPlayLater;
  final VoidCallback onPlayNext;
  final double iconSize;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPlayLater,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onPlayNext();
        },
        borderRadius: BorderRadius.circular(22),
        customBorder: const CircleBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              Symbols.playlist_add,
              size: iconSize,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
