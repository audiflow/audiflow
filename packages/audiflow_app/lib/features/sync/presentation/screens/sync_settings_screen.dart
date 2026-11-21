import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/sync_view_providers.dart';
import '../widgets/sync_labels.dart';

/// Device sync settings (plan M6d): turn sync on or join another device
/// while off; status, adding a device, the device list, and turning off
/// while on.
class SyncSettingsScreen extends ConsumerWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncStatusProvider);
    final on = switch (status.phase) {
      SyncPhase.unavailable || SyncPhase.off => false,
      _ => true,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDeviceSyncTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LayoutConstants.contentMaxWidth,
          ),
          child: ListView(
            padding: const EdgeInsets.only(top: Spacing.sm, bottom: Spacing.xl),
            children: on
                ? _onSections(context, ref, status)
                : _offSections(context, ref),
          ),
        ),
      ),
    );
  }

  List<Widget> _offSections(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return [
      GroupedSection(
        separatorIndent: SettingsRow.separatorIndentWithIcon,
        footer: l10n.syncIntro,
        children: [
          SettingsRow(
            icon: Symbols.cloud_sync,
            title: l10n.syncTurnOn,
            subtitle: l10n.syncTurnOnSubtitle,
            onTap: () => _turnOn(context, ref),
          ),
          SettingsRow(
            icon: Symbols.qr_code_scanner,
            title: l10n.syncJoin,
            subtitle: l10n.syncJoinSubtitle,
            trailing: const SettingsTrailing.chevron(),
            onTap: () => context.go(AppRoutes.settingsDeviceSyncJoin),
          ),
        ],
      ),
    ];
  }

  List<Widget> _onSections(
    BuildContext context,
    WidgetRef ref,
    SyncStatus status,
  ) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(syncControllerProvider);
    final devices = ref.watch(syncDevicesProvider);
    final ownId = controller.deviceId;
    final failure = status.phase == SyncPhase.failed
        ? syncFailureText(l10n, status.failure)
        : null;

    return [
      GroupedSection(
        header: l10n.syncStatusHeader,
        footer: failure,
        children: [SettingsRow(title: syncPhaseLabel(l10n, status.phase))],
      ),
      const SizedBox(height: Spacing.lg),
      GroupedSection(
        separatorIndent: SettingsRow.separatorIndentWithIcon,
        children: [
          SettingsRow(
            icon: Symbols.qr_code_2,
            title: l10n.syncAddDevice,
            subtitle: l10n.syncAddDeviceSubtitle,
            trailing: const SettingsTrailing.chevron(),
            onTap: () => context.go(AppRoutes.settingsDeviceSyncAdd),
          ),
        ],
      ),
      const SizedBox(height: Spacing.lg),
      GroupedSection(
        header: l10n.syncDevicesHeader,
        footer: devices.isEmpty ? l10n.syncDevicesEmpty : null,
        separatorIndent: SettingsRow.separatorIndentWithIcon,
        children: [
          for (final device in devices)
            SettingsRow(
              icon: device.platform == 'ios'
                  ? Symbols.phone_iphone
                  : Symbols.phone_android,
              title: device.name,
              subtitle: device.deviceId == ownId ? l10n.syncThisDevice : null,
            ),
        ],
      ),
      const SizedBox(height: Spacing.lg),
      GroupedSection(
        separatorIndent: SettingsRow.separatorIndentWithIcon,
        children: [
          SettingsRow(
            icon: Symbols.sync_disabled,
            title: l10n.syncTurnOff,
            onTap: () => _turnOff(context, ref),
          ),
        ],
      ),
    ];
  }

  Future<void> _turnOn(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      context,
      title: l10n.syncTurnOnConfirmTitle,
      content: l10n.syncTurnOnConfirmContent,
      action: l10n.syncTurnOn,
    );
    if (!confirmed || !context.mounted) return;
    await runSyncAction(context, ref, (c) => c.turnOn());
  }

  Future<void> _turnOff(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(
      context,
      title: l10n.syncTurnOffTitle,
      content: l10n.syncTurnOffContent,
      action: l10n.syncTurnOffAction,
    );
    if (!confirmed || !context.mounted) return;
    await runSyncAction(context, ref, (c) => c.turnOff());
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String action,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
