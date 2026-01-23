# [COMPLETED] Podcast RSS Parser Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate the external `podcast_rss_parser` package into the Audiflow monorepo as `audiflow_podcast`.

**Architecture:** Create a new package `audiflow_podcast` that wraps RSS parsing with a builder interface for zero-copy entity construction. The parser remains database-agnostic while enabling direct Drift entity construction via a `PodcastEntityBuilder` abstraction.

**Tech Stack:** Dart, XML parsing, Drift, Riverpod

**Status:** COMPLETED - Package created and integrated

---

## Overview

Migrate the external `podcast_rss_parser` package into the Audiflow monorepo as `audiflow_podcast` - a dedicated package for podcast-specific utilities and RSS parsing.

## Architecture Decision

### Package Name: `audiflow_podcast`

**Rationale:**
- Maintains semantic clarity (podcast-specific utilities)
- Follows monorepo naming convention (`audiflow_*`)
- Leaves room for future podcast-related utilities beyond just parsing
- More descriptive than generic "feed" or "rss" names

### Package Location

```
audiflow/
├── packages/
│   ├── audiflow_app/
│   ├── audiflow_core/
│   ├── audiflow_domain/
│   ├── audiflow_ui/
│   └── audiflow_podcast/          # NEW PACKAGE
│       ├── pubspec.yaml
│       ├── lib/
│       │   ├── audiflow_podcast.dart
│       │   └── src/
│       │       ├── parser/
│       │       ├── models/
│       │       ├── network/
│       │       ├── cache/
│       │       └── errors/
│       └── test/
```

### Dependency Flow

```
audiflow_app → audiflow_ui → audiflow_domain → audiflow_podcast → audiflow_core
```

## Tasks

### Task 1: Package Setup

**Files:**
- Create: `packages/audiflow_podcast/pubspec.yaml`
- Create: `packages/audiflow_podcast/lib/audiflow_podcast.dart`

**Step 1:** Create package structure
- Create `packages/audiflow_podcast/` directory
- Copy entire `lib/`, `test/` structure from external package
- Rename root export: `lib/podcast_feed_parser.dart` → `lib/audiflow_podcast.dart`

**Step 2:** Create pubspec.yaml with dependencies
```yaml
name: audiflow_podcast
description: Podcast RSS parsing utilities with streaming support
version: 0.1.0
publish_to: none

environment:
  sdk: '>=3.10.0 <4.0.0'
  flutter: '>=3.38.0'

dependencies:
  flutter:
    sdk: flutter
  audiflow_core:
    path: ../audiflow_core
  xml: ^5.4.1
  intl: ^0.19.0
  path_provider: ^2.1.0
  shared_preferences: ^2.2.0
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Task 2: Update Imports

**Files:**
- Modify: All files in `packages/audiflow_podcast/lib/src/`

Replace all `package:podcast_feed_parser/` imports → `package:audiflow_podcast/`

### Task 3: Create Builder Interface

**Files:**
- Create: `packages/audiflow_podcast/lib/src/parser/podcast_entity_builder.dart`

```dart
/// Callback interface for constructing domain entities from parsed RSS data
abstract class PodcastEntityBuilder<TFeed, TItem> {
  /// Called when feed metadata is parsed
  TFeed buildFeed(Map<String, dynamic> feedData);

  /// Called for each episode item
  TItem buildItem(Map<String, dynamic> itemData);

  /// Called when parsing error occurs
  void onError(PodcastParseError error);
}
```

### Task 4: Domain Integration

**Files:**
- Modify: `packages/audiflow_domain/pubspec.yaml`
- Create: `packages/audiflow_domain/lib/src/features/feed/builders/drift_podcast_builder.dart`
- Create: `packages/audiflow_domain/lib/src/features/feed/services/feed_parser_service.dart`

### Task 5: Testing & Validation

**Step 1:** Run melos bootstrap
```bash
cd /Users/tohru/Documents/src/projects/audiflow
melos bootstrap
```

**Step 2:** Run package tests
```bash
melos run test --scope=audiflow_podcast
```

**Step 3:** Verify code generation
```bash
cd packages/audiflow_domain
dart run build_runner build --delete-conflicting-outputs
```

## Benefits of This Architecture

1. **Clean Separation:** Podcast parsing logic independent from business logic
2. **Zero Intermediate Objects:** Parser uses builder interface to construct Drift entities directly
3. **Database Agnostic Parser:** Parser has zero knowledge of Drift or database schema
4. **Reusability:** Can be extracted and published as standalone package
5. **Testability:** Parser tested in isolation, integration tested in domain
6. **Performance:** Streaming parser + direct entity construction = zero-copy architecture

## Verification Checklist

- [x] `melos bootstrap` runs without errors
- [x] All tests pass: `melos run test`
- [x] Code generation succeeds for domain package
- [x] No circular dependencies
- [x] Parser can fetch and parse real RSS feed
- [x] Parsed data converts to Drift models correctly
- [x] Integration test passes end-to-end
- [x] Documentation updated
- [x] Architecture docs reflect new package
