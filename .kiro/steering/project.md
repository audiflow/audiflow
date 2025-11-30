# Audiflow v2 - Project Context

## What This Is

Mobile podcast player (iOS/Android) built with Flutter. Complete rewrite focusing on offline-first
experience and modern Flutter patterns.

## Core Constraints

### Platform Requirements

- Flutter 3.35+, Dart 3.9+
- iOS 14+, Android 8.0+ (API 26+)
- Mobile only (no web/desktop)
- RSS-based podcasts only

### Architecture Mandates

- Repository pattern for all data access
- Riverpod for state management
- Isar for local storage
- Feature-based module organization

## Key Features

### 1. Podcast Discovery & Management
- Browse podcast charts by region/genre
- Search podcasts via iTunes API
- Subscribe/unsubscribe to podcasts
- Automatic feed refresh
- OPML import/export support (planned)

### 2. Audio Playback
- Background audio playback
- System media controls integration
- Seekable playback with position saving
- Sleep timer
- Playback speed control
- Audio focus handling
- Phone call interruption handling

### 3. Episode Management
- Episode browsing by podcast/season
- Filter by played/unplayed/downloaded status
- Sort by episode number or date
- Episode detail view
- Playback statistics and progress

### 4. Download Management
- Offline episode downloads
- WiFi-only download option
- Batch downloads from season/episode pages
- Download queue management

### 5. Queue Management
- Adhoc queue building
- Queue reordering (swipe to remove)
- Stop at end of episode option
- Resume from last played position

### 6. Data & Sync
- Local Isar database for offline-first
- Podcast metadata caching
- Incremental RSS parsing
- Position synchronization

## Performance Targets

- App launch: <1000ms (mid-range devices)
- Feed refresh: <2s (typical podcast)
- Playback start: <500ms
- Test coverage: ≥80%

## Out of Scope (Don't Implement)

- Video podcasts, live streaming
- Podcast creation/editing tools
- Social networking features
- Web/desktop platforms
- Premium/subscription features
- Ad insertion/monetization
