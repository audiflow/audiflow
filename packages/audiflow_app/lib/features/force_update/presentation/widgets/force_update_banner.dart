import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../banner_dismissal_controller.dart';
import '../i18n_message_resolver.dart';
import '../update_url_resolver.dart';
import '../url_launcher_provider.dart';

/// Soft-update nudge rendered above the app shell when a [SoftUpdate]
/// decision is active and the user has not dismissed it this session.
///
/// Wraps a [MaterialBanner]-styled card with two actions: "Update now"
/// launches the store URL, "Later" hides the banner for the current
/// session (state lives in [softUpdateBannerDismissedProvider]).
class ForceUpdateBanner extends ConsumerWidget {
  const ForceUpdateBanner({required this.decision, super.key});

  final SoftUpdate decision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(softUpdateBannerDismissedProvider);
    if (dismissed) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);

    final message = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: locale,
      messageKey: decision.messageKey,
      messageOverride: decision.messageOverride,
      kind: ForceUpdateMessageKind.soft,
    );

    return Material(
      color: theme.colorScheme.secondaryContainer,
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.system_update_rounded,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => ref
                        .read(softUpdateBannerDismissedProvider.notifier)
                        .dismiss(),
                    child: Text(l10n.forceUpdateActionLater),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      final launcher = ref.read(urlLauncherProvider);
                      final uri = resolveUpdateUrlForCurrentPlatform(
                        configUrl: decision.updateUrl,
                      );
                      await launcher(uri);
                    },
                    child: Text(l10n.forceUpdateActionUpdateNow),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
