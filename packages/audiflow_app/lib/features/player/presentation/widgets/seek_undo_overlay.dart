import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/seek_undo_controller.dart';

/// "Go back" pill shown over the artwork after a seek jump.
///
/// Fades in while [seekUndoControllerProvider] holds an origin and out when
/// it is cleared (timeout, dismiss, go back, or episode change).
class SeekUndoOverlay extends ConsumerWidget {
  const SeekUndoOverlay({super.key, required this.onGoBack});

  /// Runs the go-back seek; the player screen wraps it in its seek guard so
  /// the play/pause icon does not flicker.
  final VoidCallback onGoBack;

  static const _fadeDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(seekUndoControllerProvider) != null;
    return AnimatedSwitcher(
      duration: _fadeDuration,
      child: isVisible
          ? _SeekUndoPill(
              key: const ValueKey('seekUndoPill'),
              onGoBack: onGoBack,
              onDismiss: () =>
                  ref.read(seekUndoControllerProvider.notifier).dismiss(),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _SeekUndoPill extends StatelessWidget {
  const _SeekUndoPill({
    super.key,
    required this.onGoBack,
    required this.onDismiss,
  });

  final VoidCallback onGoBack;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = colorScheme.onInverseSurface;

    // Sized to fit the 160 pt minimum artwork at normal text size; larger
    // text scales down rather than overflowing the artwork.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Material(
        color: colorScheme.inverseSurface,
        shape: const StadiumBorder(),
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: onGoBack,
              icon: const Icon(Symbols.undo),
              label: Text(l10n.playerSeekUndoGoBack),
              style: TextButton.styleFrom(
                foregroundColor: foreground,
                padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              tooltip: l10n.playerSeekUndoDismiss,
              icon: const Icon(Symbols.close),
              color: foreground,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
