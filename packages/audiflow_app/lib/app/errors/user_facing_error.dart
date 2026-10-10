import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart'
    show DownloadErrorType, DownloadException, NetworkException;
import 'package:audiflow_domain/audiflow_domain.dart'
    show PodcastException, isConnectivityFailure;
import 'package:audiflow_search/audiflow_search.dart'
    show SearchNetworkException;
import 'package:dio/dio.dart';

import '../../l10n/app_localizations.dart';

/// Coarse category of a failure, chosen for what the user can do about it.
enum UserFacingErrorKind {
  /// The device could not reach the server; checking the connection helps.
  network,

  /// Anything else; the user can only retry later.
  generic,
}

/// Classifies [error] into a [UserFacingErrorKind].
///
/// Unknown types fall back to [UserFacingErrorKind.generic] so internal
/// failures (storage, parsing, programming errors) never get a more
/// specific, possibly misleading message.
UserFacingErrorKind classifyUserFacingError(Object error) {
  return _isNetworkFailure(error)
      ? UserFacingErrorKind.network
      : UserFacingErrorKind.generic;
}

/// Localized message for [error] that is safe to show to the user.
///
/// Never includes the error's own text: exception strings carry internal
/// detail (database, HTTP client, URLs) that means nothing to users. Log
/// the raw error separately for diagnostics.
String userFacingErrorMessage(AppLocalizations l10n, Object error) {
  return switch (classifyUserFacingError(error)) {
    UserFacingErrorKind.network => l10n.errorNetwork,
    UserFacingErrorKind.generic => l10n.errorGeneric,
  };
}

bool _isNetworkFailure(Object error) {
  return switch (error) {
    SocketException() || NetworkException() || SearchNetworkException() => true,
    DioException() =>
      isConnectivityFailure(error) || error.error is SocketException,
    DownloadException(type: DownloadErrorType.networkUnavailable) => true,
    PodcastException() => _isPodcastConnectivityFailure(error),
    _ => false,
  };
}

/// Only [PodcastException.network] without an HTTP status marks a
/// connectivity failure. A status means the server answered; a parse-error
/// code is not trusted because the parser also reports non-network
/// failures as `NetworkError`.
bool _isPodcastConnectivityFailure(PodcastException error) {
  return error.parseError == null && error.code == 'PODCAST_NETWORK_ERROR';
}
