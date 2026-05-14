import 'package:audiflow_app/features/force_update/presentation/i18n_message_resolver.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> _en() =>
    AppLocalizations.delegate.load(const Locale('en'));
Future<AppLocalizations> _ja() =>
    AppLocalizations.delegate.load(const Locale('ja'));

void main() {
  testWidgets('resolves known key (security_critical) for hard kind', (
    tester,
  ) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'security_critical',
      messageOverride: null,
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.title).equals(l10n.forceUpdateSecurityCriticalTitle);
    check(msg.body).equals(l10n.forceUpdateSecurityCriticalBody);
  });

  testWidgets('falls back to default for unknown key', (tester) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'totally_unknown_key',
      messageOverride: null,
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.title).equals(l10n.forceUpdateDefaultTitle);
    check(msg.body).equals(l10n.forceUpdateDefaultBody);
  });

  testWidgets('soft kind uses *SoftBody fields', (tester) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'breaking_change',
      messageOverride: null,
      kind: ForceUpdateMessageKind.soft,
    );

    check(msg.body).equals(l10n.forceUpdateBreakingChangeSoftBody);
  });

  testWidgets(
    'maintenance kind uses maintenance keys regardless of messageKey',
    (tester) async {
      final l10n = await _en();
      final msg = ForceUpdateMessage.resolve(
        l10n: l10n,
        locale: const Locale('en'),
        messageKey: 'security_critical',
        messageOverride: null,
        kind: ForceUpdateMessageKind.maintenance,
      );

      check(msg.title).equals(l10n.forceUpdateMaintenanceTitle);
      check(msg.body).equals(l10n.forceUpdateMaintenanceBody);
    },
  );

  testWidgets('messageOverride takes precedence over keys, picks language', (
    tester,
  ) async {
    final l10n = await _ja();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('ja'),
      messageKey: 'default',
      messageOverride: const {'en': 'Update', 'ja': 'アップデートしてね'},
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.body).equals('アップデートしてね');
  });

  testWidgets('override falls back to en when locale missing', (tester) async {
    final l10n = await _ja();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('ja'),
      messageKey: 'default',
      messageOverride: const {'en': 'English only'},
      kind: ForceUpdateMessageKind.hard,
    );

    check(msg.body).equals('English only');
  });

  testWidgets('override applies to maintenance body too', (tester) async {
    final l10n = await _en();
    final msg = ForceUpdateMessage.resolve(
      l10n: l10n,
      locale: const Locale('en'),
      messageKey: 'maintenance',
      messageOverride: const {'en': 'Back at 9am UTC'},
      kind: ForceUpdateMessageKind.maintenance,
    );

    check(msg.title).equals(l10n.forceUpdateMaintenanceTitle);
    check(msg.body).equals('Back at 9am UTC');
  });
}
