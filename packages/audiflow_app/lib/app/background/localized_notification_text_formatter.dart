import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/duration_label.dart';
import '../app_locale.dart';

/// Formats notification text in the app's language without a
/// `BuildContext`, for use in the background isolate.
class LocalizedNotificationTextFormatter implements NotificationTextFormatter {
  LocalizedNotificationTextFormatter._(this._l10n, this._dateFormat);

  /// Resolves [storedLocale] (the language setting), or [platformLocale] when
  /// the setting follows the system, to a supported locale.
  ///
  /// Uses the foreground app's resolution, so unsupported languages fall
  /// back to English.
  static Future<LocalizedNotificationTextFormatter> create({
    required String? storedLocale,
    required String platformLocale,
  }) async {
    final locale = _resolve(storedLocale ?? platformLocale);
    final tag = locale.toLanguageTag();
    // The background isolate never ran flutter_localizations, so intl has no
    // date symbols loaded for non-default locales yet.
    await initializeDateFormatting(tag);
    return LocalizedNotificationTextFormatter._(
      lookupAppLocalizations(locale),
      DateFormat.yMMMd(tag),
    );
  }

  final AppLocalizations _l10n;
  final DateFormat _dateFormat;

  @override
  String formatDate(DateTime date) => _dateFormat.format(date.toLocal());

  @override
  String formatDuration(Duration duration) => _l10n.durationLabel(duration);

  static Locale _resolve(String localeName) {
    // Platform locale names look like `ja_JP` or `en-US`.
    final languageCode = localeName.split(RegExp('[_-]')).first;
    return resolveSupportedLocale(
      Locale(languageCode),
      AppLocalizations.supportedLocales,
    );
  }
}
