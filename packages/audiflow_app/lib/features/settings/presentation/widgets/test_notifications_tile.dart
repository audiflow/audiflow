import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../app/background/new_episode_notification_service_factory.dart';
import '../../../../app/notification/notification_permission.dart';
import '../../../../l10n/app_localizations.dart';

/// Developer action that posts sample new-episode notifications through the
/// same service the background refresh uses.
class TestNotificationsTile extends ConsumerStatefulWidget {
  const TestNotificationsTile({super.key});

  @override
  ConsumerState<TestNotificationsTile> createState() =>
      _TestNotificationsTileState();
}

class _TestNotificationsTileState extends ConsumerState<TestNotificationsTile> {
  // Blocks a second tap while artwork downloads, which would post duplicates.
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Symbols.notifications),
      title: Text(l10n.developerTestNotificationsTitle),
      subtitle: Text(l10n.developerTestNotificationsSubtitle),
      trailing: _sending
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      enabled: !_sending,
      onTap: _onTap,
    );
  }

  Future<void> _onTap() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    String message;
    try {
      message = await _send(l10n);
    } catch (e, stack) {
      ref
          .read(namedLoggerProvider('TestNotifications'))
          .e('Test notifications failed', error: e, stackTrace: stack);
      message = l10n.developerTestNotificationsFailed;
    }
    if (!mounted) return;
    setState(() => _sending = false);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  // A fresh install has not asked for notification permission yet (the app
  // asks only when new-episode notifications are enabled), and posting
  // without it would report notifications that never appear.
  Future<String> _send(AppLocalizations l10n) async {
    final permission = await resolveNotificationPermission();
    if (!permission.isGranted) {
      return l10n.developerTestNotificationsPermissionDenied;
    }
    final count = await _sender().send();
    return count == 0
        ? l10n.developerTestNotificationsNone
        : l10n.developerTestNotificationsSent(count);
  }

  TestNotificationSender _sender() => TestNotificationSender(
    subscriptionRepo: ref.read(subscriptionRepositoryProvider),
    episodeRepo: ref.read(episodeRepositoryProvider),
    post: _post,
  );

  Future<void> _post(List<NewEpisodeNotification> notifications) async {
    final service = await createNewEpisodeNotificationService(
      dio: ref.read(dioProvider),
      storedLocale: ref.read(appSettingsRepositoryProvider).getLocale(),
      logger: ref.read(namedLoggerProvider('TestNotifications')),
    );
    // Not initialized here: the foreground app already initialized the
    // plugin with its tap handler, and initializing again would replace it.
    await service.showPerEpisodeNotifications(
      FlutterLocalNotificationsPlugin(),
      notifications,
    );
  }
}
