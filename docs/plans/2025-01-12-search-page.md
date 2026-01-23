# [COMPLETED] Search Page Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a podcast search page using iTunes Search API with debounced search, loading states, and navigation to podcast details.

**Architecture:** SearchController manages search state via Riverpod. ItunesSearchDatasource handles API calls with Dio. Results displayed in scrollable list with CachedNetworkImage for artwork.

**Tech Stack:** Flutter, Riverpod, Dio, iTunes Search API, CachedNetworkImage

**Status:** COMPLETED

---

## Requirements Summary

### Functional Requirements

1. **FR-1: Search Input**
   - WHEN user types in search field, the system SHALL debounce input by 500ms
   - WHERE empty input clears results

2. **FR-2: API Integration**
   - WHEN search is triggered, the system SHALL call iTunes Search API
   - WHERE endpoint is `https://itunes.apple.com/search?media=podcast&term={query}`

3. **FR-3: Result Display**
   - WHEN results are received, the system SHALL display podcast cards
   - WHERE each card shows artwork, title, artist, and genre

4. **FR-4: Loading States**
   - WHEN search is in progress, the system SHALL show loading indicator
   - WHERE indicator is centered in the results area

5. **FR-5: Error Handling**
   - WHEN API call fails, the system SHALL display error message with retry button
   - WHERE errors include network failures and API errors

6. **FR-6: Navigation**
   - WHEN user taps a podcast card, the system SHALL navigate to podcast detail
   - WHERE podcast data is passed via route extra

### Non-Functional Requirements

- **NFR-1**: Search results SHALL appear within 2 seconds on 4G connection
- **NFR-2**: Artwork images SHALL be cached for offline viewing
- **NFR-3**: Search history SHALL NOT be persisted (privacy)

---

## Technical Design

### Component Architecture

```
SearchScreen
    ├── _SearchField (TextField with controller)
    ├── _SearchResults (Consumer widget)
    │   ├── Loading → CircularProgressIndicator
    │   ├── Error → ErrorState with retry
    │   ├── Empty → EmptyState
    │   └── Data → ListView.builder
    │       └── PodcastSearchResultTile
    └── SearchController (Riverpod notifier)
            └── ItunesSearchDatasource (Dio client)
```

### State Model

```dart
@freezed
sealed class SearchState with _$SearchState {
  const factory SearchState.initial() = SearchInitial;
  const factory SearchState.loading() = SearchLoading;
  const factory SearchState.success({required List<Podcast> podcasts}) = SearchSuccess;
  const factory SearchState.error({required String message}) = SearchError;
}
```

---

## Tasks

### Task 1: Create Search Models
- Create `Podcast` model with iTunes API field mapping
- Create `SearchState` sealed class

### Task 2: Create iTunes Datasource
- Create `ItunesSearchDatasource` with Dio
- Implement `search(String query)` method
- Add response parsing

### Task 3: Create Search Controller
- Create `SearchController` Riverpod notifier
- Implement debounced search logic
- Handle loading/error/success states

### Task 4: Create Search Screen
- Create `SearchScreen` widget
- Add search text field with decoration
- Implement results ListView

### Task 5: Create Podcast Search Result Tile
- Create reusable tile widget
- Display artwork with CachedNetworkImage
- Show title, artist, genre count

### Task 6: Wire Navigation
- Add route for search screen
- Implement navigation to podcast detail
- Pass podcast data via route extra

## Verification

1. Launch app and navigate to Search tab
2. Type a podcast name (e.g., "Joe Rogan")
3. Verify debounce - no immediate API call
4. Verify loading indicator appears
5. Verify results display with artwork
6. Tap a result - verify navigation to detail
7. Test error case by disabling network
8. Run `melos run analyze` - no errors
