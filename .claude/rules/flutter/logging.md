---
paths: **/*.dart
---
# Logging

Use the `logger` package for structured logging with colored console output.

## Logger Providers

The project provides two logger providers in `audiflow_domain`:

### appLoggerProvider
General-purpose logger for the entire application.

```dart
final logger = ref.watch(appLoggerProvider);
logger.i('Information message');
```

### namedLoggerProvider
Component-specific logger with a name prefix for easier filtering.

```dart
final logger = ref.watch(namedLoggerProvider('FeedParser'));
logger.i('Parsing feed...'); // Output: [FeedParser] Parsing feed...
```

## Log Levels

| Level | Method | Use Case |
|-------|--------|----------|
| Verbose | `logger.t()` | Detailed tracing, loop iterations |
| Debug | `logger.d()` | Development debugging |
| Info | `logger.i()` | Normal operation milestones |
| Warning | `logger.w()` | Recoverable issues |
| Error | `logger.e()` | Errors with stack traces |
| Fatal | `logger.f()` | Critical failures |

## Usage Examples

```dart
import 'package:audiflow_domain/audiflow_domain.dart';

// In a Riverpod provider or controller
@riverpod
Future<Data> fetchData(Ref ref) async {
  final logger = ref.watch(namedLoggerProvider('DataFetcher'));

  logger.i('Starting data fetch');

  try {
    final result = await api.getData();
    logger.d('Fetched ${result.length} items');
    return result;
  } catch (e, stack) {
    logger.e('Failed to fetch data', error: e, stackTrace: stack);
    rethrow;
  }
}
```

## Best Practices

- Use `namedLoggerProvider` for component-specific logging
- Use appropriate log levels (don't log everything as info)
- Include context in log messages (URLs, counts, IDs)
- Always include stack traces with errors: `logger.e('msg', error: e, stackTrace: stack)`
- Avoid logging sensitive data (tokens, passwords, PII)
