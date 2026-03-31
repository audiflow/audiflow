import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Button widget with double-tap confirmation to clear the queue.
///
/// First tap changes text to "Confirm?" with error color.
/// Second tap within 3 seconds triggers the clear action.
/// Resets after 3 seconds without confirmation.
class ClearQueueButton extends StatefulWidget {
  const ClearQueueButton({
    super.key,
    required this.onClear,
    this.enabled = true,
  });

  final VoidCallback onClear;
  final bool enabled;

  @override
  State<ClearQueueButton> createState() => _ClearQueueButtonState();
}

class _ClearQueueButtonState extends State<ClearQueueButton> {
  bool _isConfirming = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;

    if (_isConfirming) {
      // Second tap - confirm and clear
      _resetTimer?.cancel();
      setState(() => _isConfirming = false);
      widget.onClear();
    } else {
      // First tap - enter confirmation state
      setState(() => _isConfirming = true);
      _resetTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _isConfirming = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isConfirming) {
      return TextButton(
        onPressed: widget.enabled ? _handleTap : null,
        child: Text(
          l10n.queueClearConfirm,
          style: TextStyle(
            color: widget.enabled
                ? colorScheme.error
                : colorScheme.onSurface.withValues(alpha: 0.38),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: widget.enabled ? _handleTap : null,
      icon: const Icon(Icons.delete_sweep),
      tooltip: l10n.queueClearTooltip,
    );
  }
}
