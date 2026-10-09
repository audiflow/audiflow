import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/background/background_task_registrar.dart';
import '../../../../app/notification/notification_permission.dart';
import '../../../../l10n/app_localizations.dart';

/// Screen for configuring feed sync settings: auto-sync,
/// sync interval, WiFi-only sync, and new episode notifications.
class FeedSyncSettingsScreen extends ConsumerStatefulWidget {
  const FeedSyncSettingsScreen({super.key});

  @override
  ConsumerState<FeedSyncSettingsScreen> createState() =>
      _FeedSyncSettingsScreenState();
}

class _FeedSyncSettingsScreenState extends ConsumerState<FeedSyncSettingsScreen>
    with WidgetsBindingObserver {
  // Null until checked (or if the check fails): fall back to the stored
  // preference rather than flashing the switch off for granted users.
  bool? _permissionGranted;
  bool _permissionRequestInFlight = false;

  // Bumped by every status check and request; a result is applied only if
  // no newer one started meanwhile, so a slow check cannot undo a grant.
  int _permissionGeneration = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Permission can be revoked in system settings while the app is
  // backgrounded; re-check so the switch never claims notifications are on.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    if (_permissionRequestInFlight) return;
    final generation = ++_permissionGeneration;
    final PermissionStatus status;
    try {
      status = await Permission.notification.status;
    } on Exception catch (e, stack) {
      _logPermissionFailure(e, stack);
      return;
    }
    if (!mounted || generation != _permissionGeneration) return;
    await _applyPermission(status);
  }

  Future<void> _applyPermission(PermissionStatus status) async {
    setState(() => _permissionGranted = status.isGranted);
    if (status.isGranted) return;
    // Persist what the switch shows: otherwise a later grant in system
    // settings would silently enable notifications the user saw as off.
    final repo = ref.read(appSettingsRepositoryProvider);
    if (!repo.getNotifyNewEpisodes()) return;
    await _update(
      repo,
      () => repo.setNotifyNewEpisodes(false),
      replaceExisting: true,
    );
  }

  void _logPermissionFailure(Object error, StackTrace stack) {
    // ref is unusable once the screen is gone.
    if (!mounted) return;
    ref
        .read(namedLoggerProvider('FeedSyncSettings'))
        .w(
          'Notification permission call failed',
          error: error,
          stackTrace: stack,
        );
  }

  Future<void> _update(
    AppSettingsRepository repo,
    Future<void> Function() setter, {
    bool replaceExisting = false,
  }) async {
    await setter();
    // The screen may have closed mid-write (e.g. the automatic save in
    // _applyPermission): skip ref, but still re-register, which needs only
    // repo, so the background task sees the new value.
    if (mounted) ref.invalidate(appSettingsRepositoryProvider);
    await BackgroundTaskRegistrar.syncWithSettings(
      repo,
      replaceExisting: replaceExisting,
    );
  }

  Future<void> _onNotifyToggleChanged(
    AppSettingsRepository repo,
    bool enabled,
  ) async {
    if (!enabled) {
      await _update(
        repo,
        () => repo.setNotifyNewEpisodes(false),
        replaceExisting: true,
      );
      return;
    }

    // A second request while the OS dialog is open throws on Android.
    if (_permissionRequestInFlight) return;
    _permissionRequestInFlight = true;
    ++_permissionGeneration;
    final PermissionStatus status;
    try {
      status = await resolveNotificationPermission();
    } on Exception catch (e, stack) {
      _logPermissionFailure(e, stack);
      return;
    } finally {
      _permissionRequestInFlight = false;
    }
    if (!mounted) return;
    await _applyPermission(status);

    if (status.isGranted) {
      await _update(
        repo,
        () => repo.setNotifyNewEpisodes(true),
        replaceExisting: true,
      );
      return;
    }

    if (status.isPermanentlyDenied && mounted) {
      await _showNotificationPermissionDialog();
    }
  }

  Future<void> _showNotificationPermissionDialog() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.notificationPermissionRequiredTitle),
        content: Text(l10n.notificationPermissionRequiredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: Text(l10n.notificationPermissionOpenSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(appSettingsRepositoryProvider);
    final autoSync = repo.getAutoSync();
    final interval = repo.getSyncIntervalMinutes();
    final wifiOnly = repo.getWifiOnlySync();
    // The preference alone is not enough: without OS permission nothing is
    // shown, so present the switch as off and let a tap request permission.
    final notifyNewEpisodes =
        repo.getNotifyNewEpisodes() && _permissionGranted != false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsFeedSyncTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.feedSyncAutoSyncTitle),
            subtitle: Text(l10n.feedSyncAutoSyncSubtitle),
            value: autoSync,
            onChanged: HapticsScope.of(
              context,
            ).toggleHaptic((v) => _update(repo, () => repo.setAutoSync(v))),
          ),
          Visibility(
            visible: autoSync,
            child: ListTile(
              title: Text(l10n.feedSyncInterval),
              trailing: DropdownButton<int>(
                value: interval,
                onChanged: (v) {
                  if (v != null) {
                    _update(
                      repo,
                      () => repo.setSyncIntervalMinutes(v),
                      replaceExisting: true,
                    );
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: 15,
                    child: Text(l10n.feedSyncInterval15min),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: Text(l10n.feedSyncInterval30min),
                  ),
                  DropdownMenuItem(
                    value: 60,
                    child: Text(l10n.feedSyncInterval1hour),
                  ),
                  DropdownMenuItem(
                    value: 120,
                    child: Text(l10n.feedSyncInterval2hours),
                  ),
                  DropdownMenuItem(
                    value: 180,
                    child: Text(l10n.feedSyncInterval3hours),
                  ),
                  DropdownMenuItem(
                    value: 240,
                    child: Text(l10n.feedSyncInterval4hours),
                  ),
                  DropdownMenuItem(
                    value: 360,
                    child: Text(l10n.feedSyncInterval6hours),
                  ),
                  DropdownMenuItem(
                    value: 720,
                    child: Text(l10n.feedSyncInterval12hours),
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.feedSyncWifiOnlyTitle),
            subtitle: Text(l10n.feedSyncWifiOnlySubtitle),
            value: wifiOnly,
            onChanged: HapticsScope.of(context).toggleHaptic(
              (v) => _update(
                repo,
                () => repo.setWifiOnlySync(v),
                replaceExisting: true,
              ),
            ),
          ),
          Visibility(
            visible: autoSync,
            child: SwitchListTile(
              title: Text(l10n.feedSyncNotifyNewEpisodesTitle),
              subtitle: Text(l10n.feedSyncNotifyNewEpisodesSubtitle),
              value: notifyNewEpisodes,
              onChanged: HapticsScope.of(
                context,
              ).toggleHaptic((v) => _onNotifyToggleChanged(repo, v)),
            ),
          ),
        ],
      ),
    );
  }
}
