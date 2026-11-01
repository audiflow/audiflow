import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../podcast_detail/presentation/controllers/podcast_detail_controller.dart';

part 'feed_link_controller.g.dart';

/// Provider for [FeedLinkResolver].
@riverpod
FeedLinkResolver feedLinkResolver(Ref ref) {
  return FeedLinkResolver(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    itunesClient: ref.watch(itunesChartsClientProvider),
    httpClient: ref.watch(feedHttpClientProvider),
    feedParser: ref.watch(feedParserServiceProvider),
  );
}

/// Progress of opening a pasted feed link.
sealed class FeedLinkState {
  const FeedLinkState();
}

/// No link is being opened.
class FeedLinkIdle extends FeedLinkState {
  const FeedLinkIdle();
}

/// [link] is being resolved.
class FeedLinkResolving extends FeedLinkState {
  const FeedLinkResolving(this.link);

  final FeedLink link;
}

/// [link] could not be opened.
class FeedLinkFailed extends FeedLinkState {
  const FeedLinkFailed(this.link, {this.error});

  final FeedLink link;

  /// Why it failed; null for an unexpected error.
  final FeedLinkException? error;
}

/// Resolves a feed link pasted into search to the podcast to preview.
@riverpod
class FeedLinkController extends _$FeedLinkController {
  @override
  FeedLinkState build() => const FeedLinkIdle();

  /// Returns the podcast for [link], or null when it failed (the failure
  /// is in [state]) or a newer request replaced this one.
  Future<Podcast?> open(FeedLink link) async {
    final request = ++_latestRequest;
    state = FeedLinkResolving(link);
    try {
      final podcast = await ref.read(feedLinkResolverProvider).resolve(link);
      if (!_isCurrent(request)) return null;
      state = const FeedLinkIdle();
      return podcast;
    } on FeedLinkException catch (e) {
      if (!_isCurrent(request)) return null;
      // Only the failure kind: the cause carries the URL, and private feed
      // URLs embed access tokens.
      _logger.w('Feed link failed: ${e.failure}');
      state = FeedLinkFailed(link, error: e);
      // Errors too (e.g. IsarError): the panel must never stay spinning.
    } catch (e, stack) {
      if (!_isCurrent(request)) return null;
      _logger.e('Feed link failed unexpectedly', error: e, stackTrace: stack);
      state = FeedLinkFailed(link);
    }
    return null;
  }

  /// Forgets any pending or failed link, e.g. when the text changes.
  void reset() {
    _latestRequest++;
    state = const FeedLinkIdle();
  }

  // Counts requests rather than comparing links: the same link can be
  // opened again while an earlier attempt is still in flight.
  int _latestRequest = 0;

  bool _isCurrent(int request) => ref.mounted && request == _latestRequest;

  Logger get _logger => ref.read(namedLoggerProvider('FeedLink'));
}
