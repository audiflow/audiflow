/// Curated list of iTunes storefront countries with significant podcast content.
///
/// Does NOT depend on dart:io. Locale resolution is the caller's
/// responsibility (e.g., the controller reads Platform.localeName and
/// passes it to [extractCountryCode]).
class PodcastCountries {
  PodcastCountries._();

  /// Fallback country code when locale extraction fails.
  static const String fallback = 'us';

  /// Map of ISO 3166-1 alpha-2 code to English display name.
  /// Sorted alphabetically by display name.
  static const Map<String, String> all = {
    'au': 'Australia',
    'at': 'Austria',
    'be': 'Belgium',
    'br': 'Brazil',
    'ca': 'Canada',
    'cn': 'China',
    'dk': 'Denmark',
    'fi': 'Finland',
    'fr': 'France',
    'de': 'Germany',
    'hk': 'Hong Kong',
    'in': 'India',
    'id': 'Indonesia',
    'ie': 'Ireland',
    'il': 'Israel',
    'it': 'Italy',
    'jp': 'Japan',
    'kr': 'Korea',
    'mx': 'Mexico',
    'nl': 'Netherlands',
    'nz': 'New Zealand',
    'no': 'Norway',
    'pl': 'Poland',
    'pt': 'Portugal',
    'sg': 'Singapore',
    'es': 'Spain',
    'se': 'Sweden',
    'ch': 'Switzerland',
    'tw': 'Taiwan',
    'th': 'Thailand',
    'gb': 'United Kingdom',
    'us': 'United States',
  };

  /// Extracts a lowercase 2-letter country code from a platform locale string.
  ///
  /// Handles formats like `en_US`, `ja_JP`, `en`. Falls back to [fallback]
  /// if extraction fails or the code is not in [all].
  static String extractCountryCode(String locale) {
    if (locale.length < 2) return fallback;

    // Try extracting from `lang_COUNTRY` or `lang-COUNTRY` format
    final separator = locale.contains('_') ? '_' : '-';
    final parts = locale.split(separator);
    if (1 < parts.length && 2 <= parts.last.length) {
      final code = parts.last.substring(0, 2).toLowerCase();
      if (all.containsKey(code)) return code;
    }

    return fallback;
  }
}
