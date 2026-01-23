# [COMPLETED] Tab Bar Navigation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement Material 3 NavigationBar with three tabs (Search, Library, Settings) using go_router's StatefulShellRoute to preserve navigation state per tab.

**Architecture:** StatefulShellRoute with separate navigator stacks per tab, ScaffoldWithNavBar shell widget, Search as default tab.

**Tech Stack:** Flutter, go_router, Material 3 NavigationBar, material_symbols_icons

**Status:** COMPLETED

---

## Files to Create

| Path | Description |
|------|-------------|
| `packages/audiflow_app/lib/routing/scaffold_with_nav_bar.dart` | Navigation shell widget with NavigationBar |
| `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart` | Placeholder Library screen |
| `packages/audiflow_app/lib/features/settings/presentation/screens/settings_screen.dart` | Placeholder Settings screen |

## Files to Modify

| Path | Change |
|------|--------|
| `packages/audiflow_app/lib/routing/app_router.dart` | Replace simple routes with StatefulShellRoute structure |
| `packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart` | Update podcast detail navigation path |

## Tasks

### Task 1: Create ScaffoldWithNavBar widget
- Material 3 `NavigationBar` with three destinations
- Icons: `Symbols.search`, `Symbols.library_music`, `Symbols.settings`
- Filled icon variants for selected state
- Uses `StatefulNavigationShell.goBranch()` for tab switching

### Task 2: Create placeholder screens
- `LibraryScreen`: AppBar + centered icon/text placeholder
- `SettingsScreen`: AppBar + centered icon/text placeholder
- Follow existing patterns from codebase

### Task 3: Update app_router.dart
- Replace current routes with `StatefulShellRoute.indexedStack`
- Three branches with separate `GlobalKey<NavigatorState>` each
- Initial location: `/search`
- Nest podcast detail under `/search/podcast/:id`

### Task 4: Update SearchScreen navigation
- Change `context.push('${AppRoutes.podcastDetail}/${podcast.id}')`
- To `context.push('${AppRoutes.search}/podcast/${podcast.id}')`

## Route Structure

```
StatefulShellRoute
├── /search (index 0, default)
│   └── /search/podcast/:id
├── /library (index 1)
└── /settings (index 2)
```

## Verification

1. Run app: `flutter run` from `packages/audiflow_app`
2. Verify three tabs appear at bottom
3. Verify Search tab is selected by default
4. Search for a podcast, tap result to navigate to detail
5. Switch to Library tab, then back to Search - verify detail screen is preserved
6. Tap Search tab again while on detail - verify it returns to search list root
7. Verify Library and Settings show placeholder content
