import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text widget that copies its value to the clipboard on tap.
///
/// Displays [text] with an optional [label] prefix and a small copy icon.
/// Tapping copies [text] (not the label) to the clipboard and shows a
/// [SnackBar] confirmation.
class CopyableText extends StatelessWidget {
  const CopyableText({
    required this.text,
    required this.snackBarMessage,
    this.label,
    this.style,
    this.labelStyle,
    super.key,
  });

  /// The value to display and copy to clipboard.
  final String text;

  /// Optional leading label (not copied).
  final String? label;

  /// Style for the value text.
  final TextStyle? style;

  /// Style for the label text. Defaults to a dimmed variant of [style].
  final TextStyle? labelStyle;

  /// Localized snackbar message shown after copying.
  final String snackBarMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStyle = style ?? theme.textTheme.bodySmall;
    final effectiveLabelStyle =
        labelStyle ??
        theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        );

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => _copyToClipboard(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(label!, style: effectiveLabelStyle),
              const SizedBox(width: 4),
            ],
            Flexible(child: Text(text, style: effectiveStyle)),
            const SizedBox(width: 4),
            Icon(
              Icons.copy_rounded,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarMessage),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
