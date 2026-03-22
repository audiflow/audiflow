# Universal Links & Share Feature

## Problem

Episode share buttons in the episode list tiles are non-functional stubs (`onPressed: null`). The episode detail screen shares the raw RSS `episode.link` URL, which has no connection to the app. Users need a way to share episodes and podcasts via links that open directly in Audiflow when the app is installed.

## URL Scheme

Base domain: `https://audiflow.reedom.com`

| Content type | URL pattern | Example |
|-------------|-------------|---------|
| Podcast | `https://audiflow.reedom.com/p/{itunesId}` | `https://audiflow.reedom.com/p/1234567` |
| Episode | `https://audiflow.reedom.com/p/{itunesId}/e/{base64url(guid)}` | `https://audiflow.reedom.com/p/1234567/e/dGVzdC1ndWlk` |

- All URLs use `https://` scheme.
- Default servicer is Apple (iTunes). No servicer prefix needed.
- Future servicers (Spotify, Podcast Index, etc.) can use a prefix convention: `/p/spotify:{spotifyId}`.
- The `itunesId` path segment is always parsed as a `String` (not validated as numeric) to support future servicer prefixes.
- Episode GUIDs are Base64url-encoded **without padding** (RFC 4648 section 5, no `=` characters) to produce URL-safe strings.
- Station sharing is out of scope for this iteration.

## Architecture

### 1. Static Site (`audiflow-link` repo)

A separate GitHub repository deployed to GitHub Pages at `audiflow.reedom.com`.

```
audiflow-link/
├── .nojekyll                          # Disable Jekyll processing
├── .well-known/
│   ├── apple-app-site-association     # iOS Universal Links
│   └── assetlinks.json                # Android App Links
├── index.html                         # Root → store redirect
├── 404.html                           # Catch-all for ALL deep link paths
└── CNAME                              # audiflow.reedom.com
```

GitHub Pages does not support SPA routing, so `404.html` is the primary handler for all `/p/...` paths. When a browser requests `audiflow.reedom.com/p/1234567/e/xyz`, GitHub Pages returns `404.html` (with 404 status), which contains the JS redirect logic. This is fine because the page is only hit when the app is not installed — the redirect fires before the user sees any error.

#### `apple-app-site-association`

```json
{
  "applinks": {
    "details": [
      {
        "appID": "{TEAM_ID}.com.reedom.audiflow",
        "paths": ["/p/*"]
      }
    ]
  }
}
```

#### `assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.reedom.audiflow_app",
      "sha256_cert_fingerprints": ["{SIGNING_CERT_SHA256}"]
    }
  }
]
```

#### Redirect page (`404.html`)

A single HTML page with JavaScript that:
1. Detects iOS via `navigator.userAgent`
2. Redirects to App Store (iOS) or Play Store (Android)
3. Falls back to App Store link for desktop/unknown

### 2. iOS Configuration

In `packages/audiflow_app/ios/Runner/`:

- Add Associated Domains entitlement: `applinks:audiflow.reedom.com`
- Add to `Runner.entitlements`:

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:audiflow.reedom.com</string>
</array>
```

### 3. Android Configuration

In `packages/audiflow_app/android/app/src/main/AndroidManifest.xml`, add an intent-filter to the main activity:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="audiflow.reedom.com"
        android:pathPrefix="/p/" />
</intent-filter>
```

### 4. `ShareLinkBuilder` Service (`audiflow_domain`)

Located at `lib/src/features/share/services/share_link_builder.dart`.

Responsibilities:
- Look up `itunesId` from the subscription data given an Isar `Subscription.id`
- Construct the universal link URL for a podcast or episode
- Base64url-encode episode GUIDs (without padding)
- Abstract over the servicer concept (Apple default, future extensibility)

Public API:

```dart
abstract class ShareLinkBuilder {
  /// Build a universal link for a podcast.
  ///
  /// [subscriptionId] is the Isar database `Subscription.id`.
  /// Returns null if the subscription has no known servicer ID.
  Future<String?> buildPodcastLink({required int subscriptionId});

  /// Build a universal link for an episode.
  ///
  /// [subscriptionId] is the Isar database `Subscription.id`.
  /// [episodeGuid] is the RSS GUID for the episode.
  /// Returns null if the subscription has no known servicer ID.
  Future<String?> buildEpisodeLink({
    required int subscriptionId,
    required String episodeGuid,
  });
}
```

Implementation depends on `SubscriptionRepository` to look up `itunesId`. Exposed via a Riverpod provider.

Share button callers must handle the case where `episode.guid` is null (it is `String?` on `PodcastItem`). When the GUID is null, skip the universal link and fall back to `episode.link`.

### 5. `DeepLinkResolver` Service (`audiflow_domain`)

Located at `lib/src/features/share/services/deep_link_resolver.dart`.

Responsibilities:
- Parse incoming universal link URLs (must be `https://audiflow.reedom.com/p/...`)
- Resolve podcast: look up local subscription by iTunes ID, or search via iTunes API if not subscribed
- Resolve episode: find local episode by GUID under the resolved podcast, or fetch the feed if not available locally
- Return navigation targets with enough data to construct the screen

Public API:

```dart
@freezed
sealed class DeepLinkTarget with _$DeepLinkTarget {
  /// Resolved to a podcast detail screen.
  const factory DeepLinkTarget.podcast({
    required String itunesId,
    required String feedUrl,
    required String title,
    String? artworkUrl,
  }) = PodcastDeepLinkTarget;

  /// Resolved to an episode detail screen.
  const factory DeepLinkTarget.episode({
    required String itunesId,
    required PodcastItem episode,
    required String podcastTitle,
    String? artworkUrl,
    EpisodeWithProgress? progress,
  }) = EpisodeDeepLinkTarget;
}

abstract class DeepLinkResolver {
  /// Parse and resolve a universal link URI.
  /// Returns null if the URI is not a recognized audiflow link.
  /// Throws on network failure.
  Future<DeepLinkTarget?> resolve(Uri uri);
}
```

Resolution strategy:
1. Parse URI: validate scheme is `https`, host is `audiflow.reedom.com`, path starts with `/p/`
2. Extract `itunesId` and optional `encodedGuid`
3. Look up `Subscription` by `itunesId` locally
4. If not found, search iTunes API by ID to get `feedUrl`, `title`, `artworkUrl`
5. If episode GUID present, decode Base64url, look up episode locally or fetch feed
6. Return `DeepLinkTarget` with all data needed by the target screen

### 6. Deep Link Routing

#### Conflict with existing `app_links` handler

The `OpmlFileReceiverController` already listens to `AppLinks().uriLinkStream` for OPML file imports. It filters by `.opml`/`.xml` extensions, so universal links (`/p/...` paths) will not be captured by it.

Universal link handling uses GoRouter's built-in deep link support (which handles both initial links and stream links). No additional `app_links` listener is needed for `/p/...` routes.

#### Route placement

Two new top-level routes in `app_router.dart` (outside the `StatefulShellRoute.indexedStack`, at the same level as other full-screen routes like transcript):

- `/p/:itunesId` — podcast deep link
- `/p/:itunesId/e/:encodedGuid` — episode deep link

Both routes use a `DeepLinkScreen` that:
1. Shows a centered loading indicator while `DeepLinkResolver.resolve()` runs
2. On success, immediately redirects to the podcast detail or episode detail screen
3. On failure, redirects to the home screen with an error snackbar

#### `onException` handler

The current `onException` handler redirects all unknown routes to `/search`. The new `/p/:itunesId` and `/p/:itunesId/e/:encodedGuid` routes must be registered **before** the exception handler fires, so they match as valid routes. Since they are explicit top-level `GoRoute` entries, they will match before `onException`.

Error handling:
- Unresolvable podcast: redirect to home screen, show snackbar with `l10n.deepLinkPodcastNotFound`
- Unresolvable episode: navigate to podcast detail, show snackbar with `l10n.deepLinkEpisodeNotFound`
- Network failure: redirect to home screen, show snackbar with `l10n.deepLinkNetworkError`

### 7. Share Button Wiring

Four locations to update:

#### `EpisodeListTile._buildShareButton`
- Uses `ShareLinkBuilder` to construct the episode universal link
- Calls `SharePlus.instance.share(ShareParams(uri: ...))` on press
- If `episode.guid` is null or `ShareLinkBuilder` returns null, falls back to `episode.link`
- If both are null, share button remains disabled

#### `SmartPlaylistEpisodeListTile._buildShareButton`
- Same behavior as `EpisodeListTile` above
- Extract shared share logic into a helper to avoid duplication

#### `EpisodeDetailScreen` app bar share button
- Replace current `episode.link` sharing with universal link
- Same fallback chain: universal link -> `episode.link` -> disabled

#### Podcast detail screen (new)
- Add share button to the podcast detail app bar
- Uses `ShareLinkBuilder.buildPodcastLink()` to construct the podcast universal link

All share buttons need access to the subscription ID (available via the screen's subscription/podcast context). The `ShareLinkBuilder` provider handles the `itunesId` lookup internally.

## Data Flow

### Sharing (outbound)

```
User taps share → Widget calls ShareLinkBuilder
  → ShareLinkBuilder looks up itunesId from SubscriptionRepository by Subscription.id
  → Base64url-encodes episode GUID (no padding)
  → Constructs URL: https://audiflow.reedom.com/p/{itunesId}/e/{base64url(guid)}
  → Returns URL string
Widget calls SharePlus.instance.share(ShareParams(uri: url))
```

### Opening (inbound)

```
OS intercepts audiflow.reedom.com/p/... URL
  → Launches app with URI
GoRouter matches /p/:itunesId or /p/:itunesId/e/:encodedGuid
  → DeepLinkScreen shows loading indicator
  → Calls DeepLinkResolver.resolve(uri)
  → DeepLinkResolver:
      1. Validates scheme and host
      2. Parses itunesId and optional encodedGuid
      3. Looks up local subscription by itunesId
      4. If not found, searches iTunes API
      5. If episode requested, decodes Base64url GUID, looks up by GUID or fetches feed
      6. Returns DeepLinkTarget with screen-ready data
  → DeepLinkScreen redirects to podcast detail or episode detail
```

### No app installed

```
User taps link in messaging app
  → Browser navigates to audiflow.reedom.com/p/...
  → GitHub Pages returns 404.html (primary handler for all deep link paths)
  → JS detects platform
  → Redirects to App Store (iOS) or Play Store (Android)
```

## Package Placement

| Component | Package | Path |
|-----------|---------|------|
| `ShareLinkBuilder` | `audiflow_domain` | `lib/src/features/share/services/share_link_builder.dart` |
| `ShareLinkBuilderImpl` | `audiflow_domain` | `lib/src/features/share/services/share_link_builder_impl.dart` |
| `DeepLinkResolver` | `audiflow_domain` | `lib/src/features/share/services/deep_link_resolver.dart` |
| `DeepLinkResolverImpl` | `audiflow_domain` | `lib/src/features/share/services/deep_link_resolver_impl.dart` |
| `DeepLinkTarget` | `audiflow_domain` | `lib/src/features/share/models/deep_link_target.dart` |
| Share providers | `audiflow_domain` | `lib/src/features/share/providers/share_providers.dart` |
| `DeepLinkScreen` | `audiflow_app` | `lib/features/share/presentation/screens/deep_link_screen.dart` |
| Deep link routes | `audiflow_app` | `lib/routing/app_router.dart` (additions) |
| Share button updates | `audiflow_app` | Existing episode list tile + detail screen files |
| Share helper | `audiflow_app` | `lib/features/share/presentation/helpers/share_helper.dart` |
| Static site | Separate repo | `audiflow/audiflow-link` |

## Localization

New keys to add to `app_en.arb` and `app_ja.arb`:

| Key | English | Purpose |
|-----|---------|---------|
| `deepLinkPodcastNotFound` | `Podcast not found` | Snackbar when deep link podcast resolution fails |
| `deepLinkEpisodeNotFound` | `Episode not found` | Snackbar when episode resolution fails |
| `deepLinkNetworkError` | `Could not load, check your connection` | Snackbar on network failure |
| `deepLinkLoading` | `Opening link...` | Loading screen text |
| `sharePodcast` | `Share podcast` | Tooltip for podcast share button |
| `shareEpisode` | `Share episode` | Tooltip for episode share button |

## Testing

- **Unit tests**: `ShareLinkBuilder` URL construction, Base64url encoding/decoding (no padding), `DeepLinkResolver` URL parsing and resolution logic
- **Widget tests**: Share buttons trigger share with correct URLs, deep link routes navigate correctly, fallback behavior when GUID is null
- **Integration tests**: `DeepLinkScreen` loading state -> redirect flow
- **Manual verification**: iOS Universal Links and Android App Links require real device testing with the domain live

## Out of Scope

- Station sharing
- Rich link previews (Open Graph meta tags) -- future enhancement via edge function
- Analytics on link clicks
- Deferred deep linking (remembering the target if app is installed after tapping link)
- Non-Apple servicer support (URL scheme supports it, implementation is Apple-only for now)
- Rate limiting on iTunes API lookups from inbound deep links (acceptable risk for v1)
