# audiflow_app

Presentation layer for the Audiflow podcast player. Contains all screens, Riverpod controllers, GoRouter routing, localization (en/ja), and app bootstrap. No business logic lives here.

## Ecosystem context

Top-level app package in the `audiflow/` monorepo. Depends on `audiflow_domain`, `audiflow_ui`, `audiflow_core`, `audiflow_ai`, `audiflow_search`. No other package imports this one.

## Responsibilities

- Flavor entry points (`main_dev.dart`, `main_stg.dart`, `main_prod.dart`)
- Root `ProviderContainer` with Isar, Dio, SharedPreferences overrides
- GoRouter tab navigation (Search, Library, Queue, Settings) via `StatefulShellRoute.indexedStack`
- Feature screens and controllers under `lib/features/`
- Adaptive nav shell (phone bottom bar, tablet top tabs, tablet landscape rail)
- Audio handler init, mini player restore, background feed refresh (Workmanager)
- Localization: ARB files in `lib/l10n/` (en, ja)

## Non-responsibilities

- Business logic, repositories, data sources (`audiflow_domain`)
- Reusable widgets and themes (`audiflow_ui`)
- RSS parsing (`audiflow_podcast`), schema definitions (external editor repo)

## Validation

```bash
cd packages/audiflow_app && flutter analyze && flutter test
dart run build_runner build --delete-conflicting-outputs
```

## Key references

- `docs/overview.md` -- screen map, routing, localization, bootstrap sequence
- Parent `docs/architecture/` -- system overview, module boundaries

## When changing this package

- New screen: add route in `lib/routing/app_router.dart` + `AppRoutes`
- New feature: `lib/features/{name}/presentation/{controllers,screens,widgets}/`
- New l10n key: add to `app_en.arb` + `app_ja.arb`, run `flutter gen-l10n`
- New provider override: add to `ProviderContainer` in `lib/main.dart`
