# audiflow_ui

Shared UI components, theme system, and design tokens for the Audiflow podcast player. Provides reusable widgets consumed by `audiflow_app` and the Material 3 theme (light/dark) used app-wide.

## Ecosystem context

Part of the audiflow Flutter monorepo (`audiflow/packages/audiflow_ui/`). Depends on `audiflow_domain` (for model types like `DownloadTask`) and `audiflow_core` (for constants like `LayoutConstants`). Consumed exclusively by `audiflow_app`.

## Responsibilities

- Reusable widgets shared across multiple app features (cards, player components, lists, indicators)
- App-wide Material 3 theme configuration (light and dark)
- Design tokens: spacing scale, border radius constants, text styles, color scheme
- Utility functions for responsive grids and search filtering

## Non-responsibilities

- Feature-specific screens, controllers, or routing (owned by `audiflow_app`)
- Business logic, repositories, or data models (owned by `audiflow_domain`)
- Single-use widgets that appear in only one feature screen (belong in `audiflow_app`)
- State management or Riverpod providers

## Validation

```bash
cd packages/audiflow_ui && flutter test
flutter analyze .
```

## Key references

- `docs/overview.md` -- widget catalog, theme system, placement guidelines

## When changing this package

- Adding widgets: ensure they are reused by 2+ features; single-use widgets go in `audiflow_app`
- Theme changes: verify both light and dark modes render correctly
- New dependencies on `audiflow_domain` types: confirm the type is stable and exported
