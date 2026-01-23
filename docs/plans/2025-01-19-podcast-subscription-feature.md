# [COMPLETED] Podcast Subscription Feature Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement podcast channel subscription feature allowing users to subscribe/unsubscribe from podcasts with persistence in Drift database. The Library page will display subscribed channels.

**Architecture:** Subscriptions Drift table with repository pattern. SubscriptionController manages toggle state. LibraryController watches subscription stream for reactive UI updates.

**Tech Stack:** Flutter, Drift, Riverpod, Freezed

**Status:** COMPLETED

---

## Critical Files

### To Modify
- `packages/audiflow_domain/lib/src/common/database/app_database.dart` - Add Subscriptions table
- `packages/audiflow_domain/lib/audiflow_domain.dart` - Export subscription module
- `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart` - Display subscriptions
- `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart` - Add subscribe button

### To Create (audiflow_domain)
- `lib/src/features/subscription/models/subscriptions.dart` - Drift table
- `lib/src/features/subscription/repositories/subscription_repository.dart` - Interface
- `lib/src/features/subscription/repositories/subscription_repository_impl.dart` - Implementation + provider
- `lib/src/features/subscription/datasources/local/subscription_local_datasource.dart` - Drift operations

### To Create (audiflow_app)
- `lib/features/subscription/presentation/controllers/subscription_controller.dart` - Toggle subscription
- `lib/features/library/presentation/controllers/library_controller.dart` - Watch subscriptions
- `lib/features/library/presentation/widgets/subscription_list_tile.dart` - List item widget

---

## Tasks

### Task 1: Database Layer - Create Subscriptions Drift Table

**File:** `packages/audiflow_domain/lib/src/features/subscription/models/subscriptions.dart`

```dart
class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itunesId => text().unique()();
  TextColumn get feedUrl => text()();
  TextColumn get title => text()();
  TextColumn get artistName => text()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get genres => text().withDefault(const Constant(''))();
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();
  DateTimeColumn get subscribedAt => dateTime()();
  DateTimeColumn get lastRefreshedAt => dateTime().nullable()();
}
```

### Task 2: Update AppDatabase
- Add `Subscriptions` to `@DriftDatabase(tables: [Subscriptions])`
- Bump `schemaVersion` to 2
- Add migration strategy (create table for v1->v2)

### Task 3: Create Subscription Datasource
**File:** `packages/audiflow_domain/lib/src/features/subscription/datasources/local/subscription_local_datasource.dart`
- `insert()`, `delete()`, `getAll()`, `watchAll()`, `getByItunesId()`, `exists()`

### Task 4: Create Repository Interface
```dart
abstract class SubscriptionRepository {
  Future<Subscription> subscribe({...});
  Future<void> unsubscribe(String itunesId);
  Future<bool> isSubscribed(String itunesId);
  Future<List<Subscription>> getSubscriptions();
  Stream<List<Subscription>> watchSubscriptions();
}
```

### Task 5: Presentation Layer - Subscription Controller
```dart
@riverpod
class SubscriptionController extends _$SubscriptionController {
  @override
  Future<bool> build(String itunesId) async {
    return ref.watch(subscriptionRepositoryProvider).isSubscribed(itunesId);
  }

  Future<void> toggleSubscription(Podcast podcast) async {...}
}
```

### Task 6: Update Library Screen
- Convert to `ConsumerWidget`
- Watch `librarySubscriptionsProvider`
- Show loading/error/empty/list states
- Use `ListView.builder` with `SubscriptionListTile`

### Task 7: Update Podcast Detail Screen
- Add subscribe/unsubscribe toggle button
- Watch `subscriptionControllerProvider(podcast.id)`

## Verification

1. **Unit Tests**
   - Test `SubscriptionLocalDatasource` CRUD operations
   - Test `SubscriptionRepositoryImpl` logic

2. **Manual Testing**
   - Search for a podcast in Discovery
   - Navigate to podcast detail
   - Tap subscribe button -> verify button state changes
   - Navigate to Library -> verify podcast appears in list
   - Tap unsubscribe -> verify removed from Library
   - Restart app -> verify subscriptions persist

3. **Build Verification**
   ```bash
   melos run analyze
   melos run test
   ```
