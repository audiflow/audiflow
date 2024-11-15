import 'package:flutter/foundation.dart';

class Env {
  Env._();

  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN');

  static String get firebaseApiKey =>
      defaultTargetPlatform == TargetPlatform.android
          ? const String.fromEnvironment('FIREBASE_API_KEY_ANDROID')
          : const String.fromEnvironment('FIREBASE_API_KEY_IOS');

  static String get firebaseAppId =>
      const String.fromEnvironment('FIREBASE_APP_ID');

  static String get firebaseMsgSenderId =>
      const String.fromEnvironment('FIREBASE_MSG_SENDER_ID');

  static String get firebaseProjectId =>
      const String.fromEnvironment('FIREBASE_PROJECT_ID');

  static String get firebaseStorageBucket =>
      const String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static String get firebaseBundleId =>
      const String.fromEnvironment('FIREBASE_BUNDLE_ID_IOS');

  static String get mixpanelProjectToken =>
      const String.fromEnvironment('MIXPANEL_PROJECT_TOKEN');

  /// The key required when searching via PodcastIndex.org.
  static String get podcastIndexKey =>
      const String.fromEnvironment('PINDEX_KEY');

  /// The secret required when searching via PodcastIndex.org.
  static String get podcastIndexSecret =>
      const String.fromEnvironment('PINDEX_SECRET');

  /// Allows a user to override the default user agent string.
  static String get userAgentAppString =>
      const String.fromEnvironment('USER_AGENT');

  /// Link to a feedback form. This will be shown in the main overflow menu if
  /// set.
  static String get feedbackUrl => const String.fromEnvironment('FEEDBACK_URL');
}
