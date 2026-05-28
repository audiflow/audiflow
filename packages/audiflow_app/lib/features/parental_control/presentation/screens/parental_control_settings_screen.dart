import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../domain/gate_guard.dart';
import '../../providers/gate_guard_provider.dart';
import '../controllers/parental_control_controller.dart';

/// Settings screen for parental control configuration.
///
/// Shows PIN setup if no PIN is set; otherwise shows restricted-mode toggle,
/// unlock-timeout picker, and PIN-change entry.
class ParentalControlSettingsScreen extends ConsumerWidget {
  const ParentalControlSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncSettings = ref.watch(parentalControlSettingsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentalControlTitle)),
      body: asyncSettings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) =>
            Center(child: Text(l10n.parentalControlSettingsUnavailable)),
        data: (s) => _SettingsBody(settings: s),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.settings});

  final ParentalControlSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (settings.pinHashBase64 == null) {
      return ListView(
        children: [
          ListTile(
            title: Text(l10n.parentalControlPinSetupTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.parentalControlPinSetup),
          ),
        ],
      );
    }

    return ListView(
      children: [
        SwitchListTile(
          title: Text(l10n.parentalControlEnable),
          subtitle: Text(l10n.parentalControlEnableSubtitle),
          value: settings.restrictedModeEnabled,
          onChanged: (v) async {
            final guard = ref.read(gateGuardProvider);
            final ok = await guard.requireUnlock(
              context,
              reason: GateReason.parentalSettings,
            );
            if (!ok) return;
            await ref
                .read(parentalControlControllerProvider.notifier)
                .setRestrictedMode(v);
          },
        ),
        ListTile(
          title: Text(l10n.parentalControlUnlockTimeoutLabel),
          trailing: DropdownButton<int>(
            value: settings.unlockTimeoutMs,
            items: const [
              DropdownMenuItem(value: 60000, child: Text('1 min')),
              DropdownMenuItem(value: 300000, child: Text('5 min')),
              DropdownMenuItem(value: 900000, child: Text('15 min')),
            ],
            onChanged: (v) async {
              if (v == null) return;
              final guard = ref.read(gateGuardProvider);
              final ok = await guard.requireUnlock(
                context,
                reason: GateReason.parentalSettings,
              );
              if (!ok) return;
              await ref
                  .read(parentalControlControllerProvider.notifier)
                  .setUnlockTimeout(Duration(milliseconds: v));
            },
          ),
        ),
        ListTile(
          title: Text(l10n.parentalControlPinChange),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            final guard = ref.read(gateGuardProvider);
            final ok = await guard.requireUnlock(
              context,
              reason: GateReason.parentalSettings,
            );
            if (!ok) return;
            if (!context.mounted) return;
            context.push(AppRoutes.parentalControlPinChange);
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.parentalControlForgotPinBanner,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
