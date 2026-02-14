# Foundation Specification

Status: Implemented

## Monorepo Structure

Flutter workspace with Melos for monorepo management. Root `pubspec.yaml` uses `resolution: workspace`.

Five packages with strict unidirectional dependencies:

```
audiflow_app -> audiflow_ui -> audiflow_domain -> audiflow_podcast -> audiflow_core
```

- `audiflow_core`: Zero internal dependencies (foundation layer)
- `audiflow_podcast`: RSS parsing, depends only on `audiflow_core`
- `audiflow_domain`: Merged data + domain layer for zero-mapping performance
- `audiflow_ui`: Shared widgets, depends on `audiflow_domain` + `audiflow_core`
- `audiflow_app`: Main Flutter application, depends on all packages

### Merged Data + Domain Layer

`audiflow_domain` merges traditional data and domain layers. Repository interfaces and implementations coexist in the same package. Drift models serve as both database models and domain entities -- no separate DTOs.

**Rationale**: Zero mapping overhead, simpler codebase, better IDE navigation, less boilerplate.

**Trade-off accepted**: Less flexibility to swap Drift, but the project is committed to it.

## Navigation

### StatefulShellRoute

`go_router`'s `StatefulShellRoute.indexedStack` provides separate `NavigatorState` stacks per tab, preserving navigation state when switching tabs.

```
StatefulShellRoute
  /search (index 0, default)
    /search/podcast/:id
  /library (index 1)
  /queue (index 2)
  /settings (index 3)
```

`ScaffoldWithNavBar` shell widget wraps Material 3 `NavigationBar` with `material_symbols_icons`. Filled icon variants for selected state.

## Podcast Discovery

### iTunes Search

- Search via `PodcastSearchService` wrapping iTunes Search API
- 500ms debounce on search input; empty input clears results
- Search history NOT persisted (privacy decision)
- Search state uses `@freezed` sealed class: `initial`, `loading`, `success`, `error`

### Search Integration Decision

Originally planned as a separate `audiflow_search` package, but integrated directly into `audiflow_domain` as the `discovery` feature, following the merged data+domain architecture.

## RSS Parser (audiflow_podcast)

### Builder Pattern for Zero-Copy Construction

`PodcastEntityBuilder<TFeed, TItem>` abstract class enables streaming parser + direct entity construction without intermediate DTOs. The parser is database-agnostic; domain-specific entity construction happens via the builder abstraction implemented in `audiflow_domain`.

### Package Naming

Named `audiflow_podcast` (not `audiflow_rss`) for semantic clarity and future podcast-related utilities beyond parsing.

## Subscription Persistence

### Subscriptions Drift Table

Key fields: `id` (auto-increment PK), `itunesId` (unique business key), `feedUrl`, `title`, `artistName`, `artworkUrl`, `subscribedAt`, `lastRefreshedAt`.

Repository exposes both one-shot (`Future`) and reactive (`Stream`) accessors.

### SubscriptionController

Parameterized by `itunesId`: `build(String itunesId)` returns `Future<bool>` for subscription status. `LibraryController` watches subscription stream for reactive UI updates.

## CI Optimization

GitHub Actions uses `paths-ignore` (blacklist) rather than `paths` (whitelist) for CI filtering.

**Rationale**: Blacklist is more maintainable because new packages/directories are automatically included without updating the filter.

Ignored: `.claude/**`, `.github/**` (except `!.github/workflows/**`), `*.md`, `docs/**`, `.gitignore`, `.gitattributes`, `LICENSE`, `CODEOWNERS`.
