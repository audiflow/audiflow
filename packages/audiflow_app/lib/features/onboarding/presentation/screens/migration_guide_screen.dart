import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/widgets/opml_import_flow.dart';

/// Per-source migration guide. Each section describes how to
/// produce an OPML file from a third-party podcast app, then
/// hand it to audiflow.
///
/// The page opens and closes with a direct import action: most readers
/// arrive already holding an OPML file, and the page is long enough that a
/// single action at one end would be missed.
class MigrationGuideScreen extends StatelessWidget {
  const MigrationGuideScreen({super.key});

  // Dom Christie's writeup hosts a generic-OPML shortcut (forked from the
  // Pocket Casts version) plus context on what the shortcut does. We link
  // there instead of the raw iCloud install URL so users see the
  // explanation before being prompted to install a shortcut.
  static const _appleShortcutUrl =
      'https://domchristie.co.uk/posts/apple-podcasts-opml/';
  static const _pocketCastsUrl = 'https://pocketcasts.com';
  static const _overcastUrl = 'https://overcast.fm';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.migrationGuideTitle)),
      body: OpmlImportFlow(
        builder: (context, startImport) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              l10n.migrationGuideIntro,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            _ImportCallToAction(onImport: startImport),
            const SizedBox(height: 24),

            // Apple Podcasts
            _SourceHeader(text: l10n.migrationApplePodcastsTitle),
            _SourceBody(text: l10n.migrationApplePodcastsBody),
            const SizedBox(height: 16),
            _SubsectionLabel(text: l10n.migrationApplePodcastsIosLabel),
            _StepList(
              steps: [
                l10n.migrationApplePodcastsIosStep1,
                l10n.migrationApplePodcastsIosStep2,
                l10n.migrationApplePodcastsIosStep3,
                l10n.migrationApplePodcastsIosStep4,
              ],
            ),
            const SizedBox(height: 12),
            _OpenLinkButton(
              label: l10n.migrationApplePodcastsOpenShortcut,
              url: _appleShortcutUrl,
            ),
            const SizedBox(height: 16),
            _SubsectionLabel(text: l10n.migrationApplePodcastsMacLabel),
            _SourceBody(text: l10n.migrationApplePodcastsMacBody),
            const _SectionDivider(),

            // Pocket Casts
            _SourceHeader(text: l10n.migrationPocketCastsTitle),
            _SubsectionLabel(text: l10n.migrationPocketCastsWebLabel),
            _StepList(
              steps: [
                l10n.migrationPocketCastsWebStep1,
                l10n.migrationPocketCastsWebStep2,
                l10n.migrationPocketCastsWebStep3,
                l10n.migrationPocketCastsWebStep4,
              ],
            ),
            const SizedBox(height: 12),
            _OpenLinkButton(
              label: l10n.migrationPocketCastsOpenWeb,
              url: _pocketCastsUrl,
            ),
            const SizedBox(height: 16),
            _SubsectionLabel(text: l10n.migrationPocketCastsAppLabel),
            _SourceBody(text: l10n.migrationPocketCastsAppBody),
            const _SectionDivider(),

            // Overcast
            _SourceHeader(text: l10n.migrationOvercastTitle),
            _SourceBody(text: l10n.migrationOvercastBody),
            const SizedBox(height: 12),
            _StepList(
              steps: [
                l10n.migrationOvercastStep1,
                l10n.migrationOvercastStep2,
                l10n.migrationOvercastStep3,
                l10n.migrationOvercastStep4,
              ],
            ),
            const SizedBox(height: 12),
            _OpenLinkButton(
              label: l10n.migrationOvercastOpen,
              url: _overcastUrl,
            ),
            const _SectionDivider(),

            // Castbox
            _SourceHeader(text: l10n.migrationCastboxTitle),
            _SourceBody(text: l10n.migrationCastboxBody),
            const _SectionDivider(),

            // Spotify
            _SourceHeader(text: l10n.migrationSpotifyTitle),
            _SourceBody(text: l10n.migrationSpotifyBody),
            const _SectionDivider(),

            // Other
            _SourceHeader(text: l10n.migrationOtherTitle),
            _SourceBody(text: l10n.migrationOtherBody),
            const _SectionDivider(),

            _ImportCallToAction(onImport: startImport, showLocationHint: true),
          ],
        ),
      ),
    );
  }
}

/// Launches the OPML import directly from the guide, so a reader holding a
/// file does not have to find the action under Storage & Data.
class _ImportCallToAction extends StatelessWidget {
  const _ImportCallToAction({
    required this.onImport,
    this.showLocationHint = false,
  });

  final OpmlImportStarter onImport;

  /// Whether to name where the import lives, for readers who come back later.
  final bool showLocationHint;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.migrationImportCtaTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onImport,
            icon: const Icon(Symbols.file_open, size: 18),
            label: Text(l10n.migrationImportCtaButton),
          ),
        ),
        if (showLocationHint) ...[
          const SizedBox(height: 8),
          Text(
            l10n.migrationImportLocationHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _SourceHeader extends StatelessWidget {
  const _SourceHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SubsectionLabel extends StatelessWidget {
  const _SubsectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SourceBody extends StatelessWidget {
  const _SourceBody({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.5));
  }
}

class _StepList extends StatelessWidget {
  const _StepList({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${i + 1}.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    steps[i],
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OpenLinkButton extends StatelessWidget {
  const _OpenLinkButton({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => _launch(context),
        icon: const Icon(Symbols.open_in_new, size: 18),
        label: Text(label),
      ),
    );
  }

  Future<void> _launch(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final uri = Uri.parse(url);
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      ok = false;
    }
    if (!ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.migrationOpenLinkLabel)),
      );
    }
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1),
    );
  }
}
