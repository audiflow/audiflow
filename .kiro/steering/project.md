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

## Current Scope (v2.0)

**In scope:**

- Podcast search, subscription, library management
- RSS feed parsing and sync
- Audio playback with queue management
- Episode downloads and offline playback
- Multi-language: English, Japanese

**Future phases (v2.1+):**

- Smart playlists, advanced playback features
- OPML import/export, chapter support
- Optional cross-device sync

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
