# audiflow_podcast

Podcast RSS parsing utilities with streaming support for the Audiflow app.

## Features

- **Streaming RSS Parser**: Memory-efficient streaming of RSS content
- **Comprehensive Podcast Support**: Full RSS 2.0 and iTunes namespace support
- **Intelligent Caching**: Persistent storage with HTTP optimization
- **Builder Interface**: Zero-copy entity construction for custom domain models
- **Error Resilience**: Graceful handling of malformed feeds
- **Optional Logging**: Integrated logger support for debugging

## Usage

### Basic Usage with Streaming API

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';

final parser = PodcastRssParser();

// Parse from URL with default caching
await for (final entity in parser.parseFromUrl('https://example.com/feed.xml')) {
  if (entity is PodcastFeed) {
    print('Podcast: ${entity.title}');
    print('Description: ${entity.description}');
  } else if (entity is PodcastItem) {
    print('Episode: ${entity.title}');
    print('Duration: ${entity.duration}');
  }
}

// Don't forget to dispose when done
parser.dispose();
```

### Using the Builder Interface

The builder interface allows zero-copy construction of custom entity types:

```dart
import 'package:audiflow_podcast/audiflow_podcast.dart';

// Implement your own builder
class MyBuilder implements PodcastEntityBuilder<MyFeed, MyEpisode> {
  @override
  MyFeed buildFeed(Map<String, dynamic> feedData, String sourceUrl) {
    return MyFeed(
      title: feedData['title'] as String? ?? '',
      description: feedData['description'] as String? ?? '',
      // ... map other fields
    );
  }

  @override
  MyEpisode buildItem(Map<String, dynamic> itemData, String sourceUrl) {
    return MyEpisode(
      title: itemData['title'] as String? ?? '',
      guid: itemData['guid'] as String? ?? '',
      // ... map other fields
    );
  }

  @override
  void onError(PodcastParseError error) {
    print('Error: ${error.message}');
  }

  @override
  void onWarning(PodcastParseWarning warning) {
    print('Warning: ${warning.message}');
  }
}

// Use the builder
final parser = PodcastRssParser();
final result = await parser.parseWithBuilder(
  'https://example.com/feed.xml',
  builder: MyBuilder(),
);

print('Parsed ${result.items.length} episodes');
```

### Cache Options

```dart
final parser = PodcastRssParser();

final cacheOptions = CacheOptions(
  ttl: Duration(minutes: 30),
  useCache: true,
  maxCacheSize: 50 * 1024 * 1024, // 50MB
);

await for (final entity in parser.parseFromUrl(
  'https://example.com/feed.xml',
  cacheOptions: cacheOptions,
)) {
  // Handle entities...
}
```

### Parsing from Different Sources

```dart
// From URL (with caching)
parser.parseFromUrl('https://example.com/feed.xml');

// From byte stream (useful for custom HTTP clients)
parser.parseFromStream(myByteStream);

// From XML string
parser.parseFromString(xmlContent);
```

### Error Handling

```dart
await for (final entity in parser.parseFromUrl(url)) {
  if (entity is PodcastParseError) {
    print('Parsing error: ${entity.message}');
    if (entity is NetworkError) {
      print('Network issue: ${entity.originalException}');
    }
  } else {
    // Handle valid entities...
  }
}
```

### With Logging

```dart
import 'package:logger/logger.dart';

final logger = Logger();
final parser = PodcastRssParser(logger: logger);

// Now parsing operations will log debug info, warnings, and errors
await for (final entity in parser.parseFromUrl(url)) {
  // ...
}
```

## Available Feed Data Keys

The `feedData` map passed to builders contains:

| Key | Type | Description |
|-----|------|-------------|
| `title` | String | Podcast title |
| `description` | String | Podcast description |
| `link` | String? | Website URL |
| `language` | String? | Language code |
| `copyright` | String? | Copyright notice |
| `lastBuildDate` | DateTime? | Last build date |
| `pubDate` | DateTime? | Publication date |
| `itunesAuthor` | String? | iTunes author |
| `itunesImage` | String? | iTunes image URL |
| `itunesExplicit` | bool? | Explicit content flag |
| `itunesType` | String? | episodic or serial |
| `categories` | List<String>? | RSS categories |
| `itunesCategories` | List<String>? | iTunes categories |

## Available Item Data Keys

The `itemData` map passed to builders contains:

| Key | Type | Description |
|-----|------|-------------|
| `title` | String | Episode title |
| `description` | String | Episode description |
| `guid` | String? | Unique identifier |
| `pubDate` | DateTime? | Publication date |
| `enclosure` | Map? | Media file info (url, type, length) |
| `itunesDuration` | Duration? | Episode duration |
| `itunesEpisode` | int? | Episode number |
| `itunesSeason` | int? | Season number |
| `itunesEpisodeType` | String? | full, trailer, or bonus |
| `itunesImage` | String? | Episode image URL |

## Integration with audiflow_domain

The `audiflow_domain` package provides `FeedParserService` for convenient integration:

```dart
// In your Riverpod provider
final service = ref.watch(feedParserServiceProvider);
final result = await service.parseFromUrl('https://example.com/feed.xml');

print('Podcast: ${result.podcast.title}');
print('Episodes: ${result.episodeCount}');
```

## Testing

```bash
cd packages/audiflow_podcast
flutter test
```

## License

Internal package for Audiflow project.
