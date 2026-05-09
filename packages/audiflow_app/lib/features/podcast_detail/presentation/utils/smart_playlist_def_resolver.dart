import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves the [SmartPlaylistDefinition] for [playlistId] from the
/// pattern config keyed by [feedUrl].
///
/// Returns null when [feedUrl] is null, the config is still loading,
/// no definition matches, or the underlying provider errored. When
/// the provider is in an error state and a logger is provided, the
/// failure is surfaced once per call so silent config-fetch failures
/// do not masquerade as "no extractor configured".
SmartPlaylistDefinition? resolveSmartPlaylistDef({
  required WidgetRef ref,
  required String? feedUrl,
  required String playlistId,
}) {
  if (feedUrl == null) return null;
  final async = ref.watch(smartPlaylistPatternByFeedUrlProvider(feedUrl));
  return async.whenOrNull(
    data: (config) => config?.findPlaylist(playlistId),
    error: (error, stackTrace) {
      ref
          .read(namedLoggerProvider('SmartPlaylistDef'))
          .w(
            'pattern config unavailable for feedUrl=$feedUrl: $error',
            error: error,
            stackTrace: stackTrace,
          );
      return null;
    },
  );
}
