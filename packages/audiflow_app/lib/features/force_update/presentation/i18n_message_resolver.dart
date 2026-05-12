import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';

/// Which message variant to resolve for a given decision.
///
/// [hard] / [soft] share the same `messageKey` table but pick different
/// body strings; [maintenance] ignores the key and always uses the
/// maintenance pair.
enum ForceUpdateMessageKind { hard, soft, maintenance }

/// Pair of (title, body) ready to render in the UI.
@immutable
class ForceUpdateMessage {
  const ForceUpdateMessage({required this.title, required this.body});

  final String title;
  final String body;

  /// Resolves the displayable strings for a force-update decision.
  ///
  /// Behavior:
  /// - [kind] == [ForceUpdateMessageKind.maintenance] always uses the
  ///   maintenance title/body and ignores [messageKey].
  /// - Otherwise the entry for [messageKey] is looked up in the table;
  ///   an unknown key falls back to `default`.
  /// - [messageOverride] (when non-null) takes precedence over the
  ///   localized body. Language picks: current locale → `en` → first.
  static ForceUpdateMessage resolve({
    required AppLocalizations l10n,
    required Locale locale,
    required String messageKey,
    required Map<String, String>? messageOverride,
    required ForceUpdateMessageKind kind,
  }) {
    if (kind == ForceUpdateMessageKind.maintenance) {
      return ForceUpdateMessage(
        title: l10n.forceUpdateMaintenanceTitle,
        body: messageOverride != null
            ? _pickOverride(messageOverride, locale)
            : l10n.forceUpdateMaintenanceBody,
      );
    }

    final entry = _entries[messageKey] ?? _entries['default']!;
    final title = entry.title(l10n);
    final body = messageOverride != null
        ? _pickOverride(messageOverride, locale)
        : (kind == ForceUpdateMessageKind.soft
              ? entry.softBody(l10n)
              : entry.body(l10n));

    return ForceUpdateMessage(title: title, body: body);
  }

  static String _pickOverride(Map<String, String> override, Locale locale) {
    final byLocale = override[locale.languageCode];
    if (byLocale != null) return byLocale;
    final byEnglish = override['en'];
    if (byEnglish != null) return byEnglish;
    return override.values.first;
  }
}

typedef _L = String Function(AppLocalizations);

class _Entry {
  const _Entry({
    required this.title,
    required this.body,
    required this.softBody,
  });

  final _L title;
  final _L body;
  final _L softBody;
}

final Map<String, _Entry> _entries = {
  'default': _Entry(
    title: (l) => l.forceUpdateDefaultTitle,
    body: (l) => l.forceUpdateDefaultBody,
    softBody: (l) => l.forceUpdateDefaultSoftBody,
  ),
  'security_critical': _Entry(
    title: (l) => l.forceUpdateSecurityCriticalTitle,
    body: (l) => l.forceUpdateSecurityCriticalBody,
    softBody: (l) => l.forceUpdateSecurityCriticalSoftBody,
  ),
  'breaking_change': _Entry(
    title: (l) => l.forceUpdateBreakingChangeTitle,
    body: (l) => l.forceUpdateBreakingChangeBody,
    softBody: (l) => l.forceUpdateBreakingChangeSoftBody,
  ),
  'os_drift': _Entry(
    title: (l) => l.forceUpdateOsDriftTitle,
    body: (l) => l.forceUpdateOsDriftBody,
    softBody: (l) => l.forceUpdateOsDriftSoftBody,
  ),
};
