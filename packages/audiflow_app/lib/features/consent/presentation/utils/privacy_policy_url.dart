/// Canonical host serving the audiflow privacy policy page.
///
/// The page is part of the reedom company site and supports `?lang=` and
/// `?embed=1` query params for in-app surfacing.
const _kPrivacyPolicyHost = 'company.reedom.com';

/// Language codes the policy page supports today.
const _kSupportedLangs = {'en', 'ja'};

/// Builds the canonical privacy policy URL for the consent flow.
///
/// Unsupported [lang] codes fall back to English so the user never lands on
/// a missing translation. Set [embed] to false only when opening outside the
/// in-app browser (e.g. sharing a public link).
Uri buildPrivacyPolicyUrl({required String lang, bool embed = true}) {
  final resolvedLang = _kSupportedLangs.contains(lang) ? lang : 'en';
  return Uri(
    scheme: 'https',
    host: _kPrivacyPolicyHost,
    path: '/audiflow/privacy-policy',
    queryParameters: {'lang': resolvedLang, if (embed) 'embed': '1'},
  );
}
