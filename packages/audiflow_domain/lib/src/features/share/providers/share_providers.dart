import 'package:audiflow_search/audiflow_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feed/repositories/episode_repository_impl.dart';
import '../../feed/services/feed_parser_service.dart';
import '../../subscription/repositories/subscription_repository_impl.dart';
import '../services/deep_link_resolver.dart';
import '../services/deep_link_resolver_impl.dart';
import '../services/share_link_builder.dart';
import '../services/share_link_builder_impl.dart';

part 'share_providers.g.dart';

@Riverpod(keepAlive: true)
ItunesChartsClient itunesChartsClient(Ref ref) {
  return ItunesChartsClient();
}

@riverpod
ShareLinkBuilder shareLinkBuilder(Ref ref) {
  return ShareLinkBuilderImpl();
}

@riverpod
DeepLinkResolver deepLinkResolver(Ref ref) {
  return DeepLinkResolverImpl(
    subscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    episodeRepository: ref.watch(episodeRepositoryProvider),
    feedParserService: ref.watch(feedParserServiceProvider),
    itunesChartsClient: ref.watch(itunesChartsClientProvider),
  );
}
