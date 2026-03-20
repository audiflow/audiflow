# State Flow

## Definitions

- **Provider**: A Riverpod-managed unit of state, created via `@riverpod` code generation
- **KeepAlive provider**: A provider that persists for the app's lifetime (`@Riverpod(keepAlive: true)`)
- **AsyncValue**: Riverpod's wrapper for async state with `data`, `loading`, and `error` variants

## State management approach

All state is managed through Riverpod with code generation (`@riverpod` annotation). There are no StateNotifiers, ChangeNotifiers, or manual StreamControllers for app state.

## State categories

### 1. App-lifetime state (keepAlive: true)

These providers persist across navigation and screen changes:

| Provider | Package | Purpose |
|----------|---------|---------|
| `audioPlayerProvider` | audiflow_domain | Singleton `AudioPlayer` instance |
| `playbackProgressStreamProvider` | audiflow_domain | Combined position/duration/buffered stream |
| `playbackSpeedProvider` | audiflow_domain | Current playback speed stream |
| `nowPlayingControllerProvider` | audiflow_domain | Currently playing episode metadata |
| `audioPlayerControllerProvider` | audiflow_domain | Play/pause/seek/stop commands |

### 2. Feature state (auto-disposed)

These providers are created when watched and disposed when no longer observed:

- Feed/subscription providers: podcast list, episode list, feed sync status
- Queue providers: queue items, queue reordering state
- Download providers: download tasks, download progress
- Settings providers: app settings, playback preferences
- Search/discovery providers: search results, chart data
- Transcript providers: transcript segments, chapter data
- Station providers: station list, station detail, station edit state, station episode lists

### 3. UI-only state

Ephemeral state local to a widget, managed with Flutter hooks (`flutter_hooks`) or `StatefulWidget`:

- Animation controllers
- Text field focus
- Scroll position
- Expansion/collapse state

## Data flow pattern

```
UI (ConsumerWidget)
  |-- ref.watch(featureControllerProvider)  --> triggers rebuild on state change
  |-- ref.read(featureControllerProvider.notifier).doAction()  --> one-time mutation
  |
  v
Controller (@riverpod class, in audiflow_app)
  |-- ref.watch(repositoryProvider)  --> injects dependency
  |
  v
Repository (interface in audiflow_domain)
  |-- local datasource (Isar)     --> read/write Isar collections
  |-- remote datasource (Dio)     --> HTTP fetch
  |
  v
Isar collection class  --> used directly as domain entity (no DTO mapping)
```

## Cross-feature communication

Features communicate through event streams, not direct provider coupling:

```
PlayerEvent stream (audiflow_domain)
  |-- PlaybackStarted, PlaybackPaused, PlaybackCompleted
  |-- Watched by: queue service, history service, analytics, station reconciler

DownloadEvent stream (audiflow_domain)
  |-- DownloadCompleted, DownloadFailed
  |-- Watched by: feed service (update episode download status), station reconciler

SubscriptionEvent stream (audiflow_domain)
  |-- Subscribed, Unsubscribed
  |-- Watched by: station reconciler (update station podcast membership)

FeedSyncEvent stream (audiflow_domain)
  |-- SyncCompleted
  |-- Watched by: station reconciler (reconcile station episodes)
```

Pattern: Define a `sealed class` for events, expose via `@Riverpod(keepAlive: true)` stream provider.

## Playback state machine

```
idle --> loading --> playing <--> paused
  ^        |           |           |
  |        v           v           v
  +------- error <-----+-----------+
```

States defined in `PlaybackState` (freezed sealed class):
- `PlaybackState.idle()`: No audio loaded
- `PlaybackState.loading(episodeUrl)`: Audio source being prepared
- `PlaybackState.playing(episodeUrl)`: Audio actively playing
- `PlaybackState.paused(episodeUrl)`: Audio paused
- `PlaybackState.error(message)`: Error during playback

## Provider side effects

Use `ref.listen()` for side effects triggered by state changes:

- Navigation on auth state change
- Snackbar on error state
- Position save on playback progress (debounced)
- Analytics event on playback start/complete

## When to update

Update when: new keepAlive providers added, state management pattern changes, cross-feature event contracts change, playback state machine modified.
