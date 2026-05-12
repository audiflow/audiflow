import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../force_update_controller.dart';
import '../i18n_message_resolver.dart';
import '../update_url_resolver.dart';
import '../url_launcher_provider.dart';

/// Full-screen splash blocking the app on [HardUpdate] or [Maintenance].
///
/// Renders the localized message, an app-branded icon, and a single primary
/// action. Back navigation and system-gesture dismiss are disabled via
/// [PopScope] so users cannot reach the underlying router.
class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({required this.decision, super.key});

  /// Decision under display. Must be [HardUpdate] or [Maintenance];
  /// other variants are treated as a no-op render.
  final ActionableUpdateDecision decision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final isMaintenance = decision is Maintenance;

    final message = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: locale,
      messageKey: decision.messageKey,
      messageOverride: decision.messageOverride,
      kind: isMaintenance
          ? ForceUpdateMessageKind.maintenance
          : ForceUpdateMessageKind.hard,
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    isMaintenance
                        ? Icons.construction_rounded
                        : Icons.system_update_rounded,
                    size: 96,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: Spacing.xl),
                  Text(
                    message.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    message.body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: Spacing.xl),
                  if (isMaintenance)
                    _MaintenanceActions(decision: decision)
                  else
                    _HardUpdateAction(decision: decision),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HardUpdateAction extends ConsumerWidget {
  const _HardUpdateAction({required this.decision});

  final ActionableUpdateDecision decision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FilledButton(
      onPressed: () async {
        final launcher = ref.read(urlLauncherProvider);
        final uri = resolveUpdateUrlForCurrentPlatform(
          configUrl: decision.updateUrl,
        );
        await launcher(uri);
      },
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      child: Text(l10n.forceUpdateActionUpdateNow),
    );
  }
}

class _MaintenanceActions extends ConsumerWidget {
  const _MaintenanceActions({required this.decision});

  final ActionableUpdateDecision decision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return FilledButton(
      onPressed: () {
        // Fire and forget: controller serializes refreshes internally.
        ref.read(forceUpdateControllerProvider.notifier).refresh();
      },
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      child: Text(l10n.forceUpdateActionRetry),
    );
  }
}
