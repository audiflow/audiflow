# audiflow_podcast

Streaming podcast RSS feed parser for Dart and Flutter. Parses RSS 2.0 feeds with iTunes namespace support, podcast:transcript, and podcast:chapters extraction using a memory-efficient streaming architecture.

## Ecosystem context

Depends only on audiflow_core. Consumed by audiflow_domain (feed sync) and audiflow_cli (feed debugging). No knowledge of Isar, Riverpod, or app-layer concerns.

## Responsibilities

- Streaming XML parsing of RSS feeds via `PodcastRssParser` (URL, byte stream, or string input)
- RSS 2.0 + iTunes namespace field extraction (`PodcastFeed`, `PodcastItem`)
- Transcript parsing: SRT (`SrtParser`) and VTT (`VttParser`) via `TranscriptFileParser`
- Chapter extraction (`PodcastChapter`)
- HTTP feed fetching with cache-first strategy (`HttpFetcher`, `CacheManager`, `CacheOptions`)
- Builder interface (`PodcastEntityBuilder`) for zero-copy entity construction
- Isolate-based parsing (`IsolateRssParser`) for background processing
- Parse progress reporting (`ParseProgress`)
- Blank-to-null normalization for optional fields (owner name/email, URLs) via `EntityFactory`
- Graceful handling of malformed feeds (`PodcastParseError`, `NetworkError`, `XmlParsingError`)

## Non-responsibilities

- Persisting parsed data to database (owned by audiflow_domain)
- Podcast search/discovery (owned by audiflow_search)
- UI rendering of feed content
- Smart playlist logic

## Key entry points

- `lib/audiflow_podcast.dart` -- barrel file (full API)
- `lib/parser.dart` -- parser-only exports (used by audiflow_cli)
- `lib/src/podcast_feed_parser.dart` -- `PodcastRssParser` main class with `parseFromUrl()`, `parseFromStream()`, `parseFromString()`, `parseWithBuilder()`

## Validation

```bash
cd packages/audiflow_podcast && flutter test
flutter analyze .
```
