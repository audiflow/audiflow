import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

/// Picks the supported locale whose language code matches [locale], falling
/// back to the first supported locale (English).
///
/// Used as `localeResolutionCallback`, which Flutter runs for both the device
/// locale and an explicit `MaterialApp.locale`.
Locale resolveSupportedLocale(
  Locale? locale,
  Iterable<Locale> supportedLocales,
) {
  return supportedLocales.firstWhere(
    (supported) => supported.languageCode == locale?.languageCode,
    orElse: () => supportedLocales.first,
  );
}

/// Keeps [intl.Intl.defaultLocale] in step with the app's resolved locale so
/// date and number formatting follow the chosen language.
///
/// This lives below [Localizations] rather than in the resolution callback
/// because Flutter reuses its cached device-locale resolution, without calling
/// the callback, when `MaterialApp.locale` goes back to `null`.
class IntlLocaleSync extends StatelessWidget {
  const IntlLocaleSync({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    intl.Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
    return child;
  }
}
