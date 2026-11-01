import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Asks for a feed URL or podcast link; returns the entered text once it
/// parses as a link, or null when cancelled.
class FeedUrlDialog extends StatefulWidget {
  const FeedUrlDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const FeedUrlDialog(),
    );
  }

  @override
  State<FeedUrlDialog> createState() => _FeedUrlDialogState();
}

class _FeedUrlDialogState extends State<FeedUrlDialog> {
  final _controller = TextEditingController();
  bool _showInvalid = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (parseFeedLink(text) == null) {
      setState(() => _showInvalid = true);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.feedLinkAddByUrl),
      content: TextField(
        key: const Key('feed_url_dialog_field'),
        controller: _controller,
        autofocus: true,
        autocorrect: false,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.go,
        decoration: InputDecoration(
          hintText: l10n.feedLinkDialogHint,
          errorText: _showInvalid ? l10n.feedLinkDialogInvalid : null,
          errorMaxLines: 3,
        ),
        onChanged: (_) {
          if (_showInvalid) setState(() => _showInvalid = false);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.feedLinkOpen)),
      ],
    );
  }
}
