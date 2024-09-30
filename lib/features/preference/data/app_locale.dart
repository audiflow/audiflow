import 'dart:ui';

import 'package:audiflow/common/data/device_locale.dart';
import 'package:audiflow/constants/locale.dart';
import 'package:audiflow/features/preference/data/preference_repository.dart';
import 'package:intl/locale.dart' as intl;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_locale.g.dart';

@Riverpod(keepAlive: true)
Locale appLocale(AppLocaleRef ref) {
  final prefLocale =
      ref.read(preferenceRepositoryProvider.select((pref) => pref.locale));
  final deviceLocale = ref.watch(deviceLocaleProvider);

  if (prefLocale != undefinedLocale.toString()) {
    final parsed = intl.Locale.tryParse(prefLocale);
    if (parsed != null) {
      return Locale(parsed.languageCode, parsed.countryCode);
    }
  }

  return deviceLocale;
}
