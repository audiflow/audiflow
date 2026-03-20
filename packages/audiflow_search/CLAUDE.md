# audiflow_search

Podcast search and discovery API client for the audiflow app. Provides search and chart retrieval via the iTunes Search API, with a provider-based architecture for future backend extensibility.

## Ecosystem context

Depends only on audiflow_core. Consumed by audiflow_domain (discovery feature). Uses Dio for HTTP and Freezed for immutable models.

## Responsibilities

- Podcast search via `PodcastSearchService.search(SearchQuery)` and `getTopCharts(ChartsQuery)`
- Builder pattern for zero-copy entity construction (`PodcastSearchEntityBuilder`, `searchWithBuilder()`)
- Multi-provider aggregation with deduplication
- iTunes provider implementation (`ItunesProvider`)
- Provider abstraction (`PodcastProvider` interface with `providerId`, `supportsCharts`)
- Freezed models: `Podcast`, `SearchResult`, `SearchQuery`, `ChartsQuery`, `ItunesGenre`
- Typed exceptions (`SearchException`) with status codes

## Non-responsibilities

- RSS feed parsing (owned by audiflow_podcast)
- Persisting search results to database (owned by audiflow_domain)
- UI for search screens (owned by audiflow_app)
- Subscription management

## Key entry points

- `lib/audiflow_search.dart` -- barrel file
- `lib/src/services/podcast_search_service.dart` -- `PodcastSearchService.create(providers:)`
- `lib/src/providers/itunes_provider.dart` -- `ItunesProvider`
- `lib/src/builders/podcast_search_entity_builder.dart` -- builder interface

## Validation

```bash
cd packages/audiflow_search && flutter test
flutter analyze .
```
