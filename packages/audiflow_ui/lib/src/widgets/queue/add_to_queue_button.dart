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
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onPlayNext();
      },
      child: IconButton(
        icon: Icon(Symbols.playlist_add, size: iconSize),
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        onPressed: onPlayLater,
      ),
    );
  }
}
