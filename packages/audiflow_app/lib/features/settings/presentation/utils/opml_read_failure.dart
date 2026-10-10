import '../../../../app/errors/user_facing_error.dart';
import '../../../../l10n/app_localizations.dart';

/// Why an OPML file could not be turned into a list of podcast feeds.
enum OpmlReadFailure {
  /// The file could not be read, or its content is not valid OPML.
  unreadableFile,

  /// The file is valid OPML but lists no podcast feeds.
  noFeeds,

  /// Any other failure, such as a storage error while checking
  /// subscriptions.
  unexpected,
}

/// Localized, user-facing text for an [OpmlReadFailure].
extension OpmlReadFailureMessage on OpmlReadFailure {
  /// [error] is the underlying failure, used only to pick the wording of
  /// [OpmlReadFailure.unexpected]; its own text is never shown.
  String message(AppLocalizations l10n, Object? error) {
    return switch (this) {
      OpmlReadFailure.unreadableFile => l10n.opmlFileUnreadable,
      OpmlReadFailure.noFeeds => l10n.opmlNoFeedsFound,
      OpmlReadFailure.unexpected =>
        error == null ? l10n.errorGeneric : userFacingErrorMessage(l10n, error),
    };
  }
}
