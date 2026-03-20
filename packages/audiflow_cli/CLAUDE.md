# audiflow_cli

CLI tools for debugging audiflow domain and podcast features. Developer-only package, not shipped in the app.

## Ecosystem context

Depends on audiflow_domain and audiflow_podcast. Uses domain pattern models and the RSS parser to inspect smart playlist extraction against live feeds.

## Responsibilities

- Smart playlist debug command: fetch a live RSS feed and run title/episode extraction diagnostics (`SmartPlaylistDebugCommand`)
- Pattern listing and testing (`PatternListCommand`, `PatternTestCommand`)
- Title extractor diagnostics (`TitleExtractorDiagnostics`)
- Episode extractor diagnostics (`SmartPlaylistEpisodeExtractorDiagnostics`)
- Pattern registry for matching feed URLs to known configs (`PatternRegistry`)
- Episode adapter converting `PodcastItem` to domain `EpisodeData` (`toEpisode()`)
- Output as table or JSON (`TableReporter`, `JsonReporter`)

## Non-responsibilities

- App runtime behavior
- UI rendering
- Database operations
- Production deployment

## Key entry points

- `lib/audiflow_cli.dart` -- barrel file
- `lib/src/commands/smart_playlist_debug_command.dart` -- main debug command (`run(feedUrl:, patternId:, json:)`)
- `lib/src/patterns/pattern_registry.dart` -- feed URL to pattern matching

## Validation

```bash
cd packages/audiflow_cli && flutter test
flutter analyze packages/audiflow_cli
```
