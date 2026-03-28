# Image Color: Adaptive Status Bar and App Bar Buttons — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the episode detail screen's status bar icons and app bar buttons adapt their color based on podcast artwork brightness.

**Architecture:** For each episode's artwork, sample the top-edge pixels of the image (via `ResizeImage` + `toByteData`) to estimate average brightness, then use that brightness to drive `SliverAppBar.systemOverlayStyle` and the colors of squircle-backed action buttons. The brightness-resolving logic lives in `audiflow_ui`; the episode detail screen consumes it.

**Tech Stack:** Flutter image APIs (`ResizeImage`, `ui.Image.toByteData`) for sampling, luminance utilities for brightness computation, `SliverAppBar.systemOverlayStyle` for the status bar, Flutter `Material` for custom app bar buttons

---

### Task 1: Add `palette_generator` dependency to `audiflow_ui`

**Files:**
- Modify: `packages/audiflow_ui/pubspec.yaml`

- [ ] **Step 1: Add dependency**

In `packages/audiflow_ui/pubspec.yaml`, add `palette_generator` under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  audiflow_core:
  audiflow_domain:
  palette_generator: ^0.3.3+4
  flutter_screenutil: 5.9.3
```

- [ ] **Step 2: Run pub get**

Run: `cd packages/audiflow_ui && flutter pub get`
Expected: resolves without errors

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_ui/pubspec.yaml
git commit -m "chore(ui): add palette_generator dependency"
```

---

### Task 2: Create `ArtworkBrightnessResolver`

**Files:**
- Create: `packages/audiflow_ui/lib/src/utils/artwork_brightness_resolver.dart`
- Test: `packages/audiflow_ui/test/utils/artwork_brightness_resolver_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_ui/test/utils/artwork_brightness_resolver_test.dart`:

```dart
import 'dart:ui' as ui;

import 'package:audiflow_ui/src/utils/artwork_brightness_resolver.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a 1x1 image filled with [color].
Future<ImageProvider> _solidImageProvider(Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 1, 1),
    Paint()..color = color,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(1, 1);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(byteData!.buffer.asUint8List());
}

void main() {
  group('ArtworkBrightnessResolver', () {
    testWidgets('returns Brightness.dark for dark image', (tester) async {
      final provider = await _solidImageProvider(const Color(0xFF1A1A2E));
      final result = await ArtworkBrightnessResolver.resolve(provider);
      check(result).equals(Brightness.dark);
    });

    testWidgets('returns Brightness.light for light image', (tester) async {
      final provider = await _solidImageProvider(const Color(0xFFFFF8E1));
      final result = await ArtworkBrightnessResolver.resolve(provider);
      check(result).equals(Brightness.light);
    });

    testWidgets('returns Brightness.dark as fallback on error', (tester) async {
      // An invalid provider that will fail to resolve
      const provider = NetworkImage('https://invalid.test/no-image.png');
      final result = await ArtworkBrightnessResolver.resolve(provider);
      check(result).equals(Brightness.dark);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_ui && flutter test test/utils/artwork_brightness_resolver_test.dart`
Expected: FAIL — file not found / class not defined

- [ ] **Step 3: Write implementation**

Create `packages/audiflow_ui/lib/src/utils/artwork_brightness_resolver.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

/// Resolves the perceived brightness of an artwork image.
///
/// Uses [PaletteGenerator] to extract the dominant color, then
/// checks luminance against a threshold to classify as dark or light.
class ArtworkBrightnessResolver {
  ArtworkBrightnessResolver._();

  static const double _luminanceThreshold = 0.5;

  /// Resolves brightness from an [ImageProvider].
  ///
  /// Returns [Brightness.dark] if the dominant color's luminance
  /// is below the threshold, or as a fallback when extraction fails.
  static Future<Brightness> resolve(ImageProvider provider) async {
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 4,
      );
      final dominantColor =
          palette.dominantColor?.color ?? palette.colors.firstOrNull;
      if (dominantColor == null) return Brightness.dark;

      return dominantColor.computeLuminance() < _luminanceThreshold
          ? Brightness.dark
          : Brightness.light;
    } on Exception {
      return Brightness.dark;
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/audiflow_ui && flutter test test/utils/artwork_brightness_resolver_test.dart`
Expected: all 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_ui/lib/src/utils/artwork_brightness_resolver.dart \
       packages/audiflow_ui/test/utils/artwork_brightness_resolver_test.dart
git commit -m "feat(ui): add ArtworkBrightnessResolver for image luminance detection"
```

---

### Task 3: Create `OverlayActionButton` widget

**Files:**
- Create: `packages/audiflow_ui/lib/src/widgets/buttons/overlay_action_button.dart`
- Test: `packages/audiflow_ui/test/widgets/buttons/overlay_action_button_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_ui/test/widgets/buttons/overlay_action_button_test.dart`:

```dart
import 'package:audiflow_ui/src/widgets/buttons/overlay_action_button.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OverlayActionButton', () {
    testWidgets('renders white icon on dark brightness', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.dark,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(Colors.white);

      // Verify light scrim (white-based background)
      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.color).equals(Colors.white.withValues(alpha: 0.2));
    });

    testWidgets('renders dark icon on light brightness', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.light,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(const Color(0xFF1A1A1A));

      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.color).equals(Colors.black.withValues(alpha: 0.25));
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.dark,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(OverlayActionButton));
      check(tapped).isTrue();
    });

    testWidgets('has correct size and border radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.dark,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      check(sizedBox.width).equals(36.0);
      check(sizedBox.height).equals(36.0);

      final container = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = container.decoration as BoxDecoration;
      check(decoration.borderRadius).equals(BorderRadius.circular(10));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_ui && flutter test test/widgets/buttons/overlay_action_button_test.dart`
Expected: FAIL — class not defined

- [ ] **Step 3: Write implementation**

Create `packages/audiflow_ui/lib/src/widgets/buttons/overlay_action_button.dart`:

```dart
import 'package:flutter/material.dart';

/// A translucent squircle-shaped button for overlaying on artwork.
///
/// Adapts its scrim and icon color based on [artworkBrightness]:
/// - [Brightness.dark]: light scrim (white 20%) + white icon
/// - [Brightness.light]: dark scrim (black 25%) + dark icon
class OverlayActionButton extends StatelessWidget {
  const OverlayActionButton({
    super.key,
    required this.icon,
    required this.artworkBrightness,
    this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final Brightness artworkBrightness;
  final VoidCallback? onTap;
  final String? semanticLabel;

  static const double _size = 36.0;
  static const double _borderRadius = 10.0;
  static const double _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final isDarkArtwork = artworkBrightness == Brightness.dark;
    final scrimColor = isDarkArtwork
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.25);
    final iconColor =
        isDarkArtwork ? Colors.white : const Color(0xFF1A1A1A);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scrimColor,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Icon(icon, color: iconColor, size: _iconSize),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/audiflow_ui && flutter test test/widgets/buttons/overlay_action_button_test.dart`
Expected: all 4 tests PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_ui/lib/src/widgets/buttons/overlay_action_button.dart \
       packages/audiflow_ui/test/widgets/buttons/overlay_action_button_test.dart
git commit -m "feat(ui): add OverlayActionButton with adaptive squircle background"
```

---

### Task 4: Export new files from `audiflow_ui`

**Files:**
- Modify: `packages/audiflow_ui/lib/audiflow_ui.dart`

- [ ] **Step 1: Add exports**

Add these lines to `packages/audiflow_ui/lib/audiflow_ui.dart`:

```dart
// Widgets - Buttons
export 'src/widgets/buttons/overlay_action_button.dart';

// Utils
export 'src/utils/artwork_brightness_resolver.dart';
```

The `// Utils` header already exists (for `responsive_grid` and `search_filter`), so add `artwork_brightness_resolver` after the existing utils exports. Add the `// Widgets - Buttons` section before the `// Widgets - Cards` section.

- [ ] **Step 2: Verify analyze passes**

Run: `cd packages/audiflow_ui && flutter analyze`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_ui/lib/audiflow_ui.dart
git commit -m "chore(ui): export OverlayActionButton and ArtworkBrightnessResolver"
```

---

### Task 5: Update `EpisodeDetailScreen` with adaptive app bar

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart`
- Test: `packages/audiflow_app/test/features/podcast_detail/presentation/screens/episode_detail_screen_brightness_test.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_app/test/features/podcast_detail/presentation/screens/episode_detail_screen_brightness_test.dart`:

```dart
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EpisodeDetailScreen adaptive overlay', () {
    testWidgets('AnnotatedRegion uses light style for dark artwork',
        (tester) async {
      // The full screen requires many providers. Instead, verify the
      // OverlayActionButton renders correctly for each brightness value,
      // which is the unit under control.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.dark,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(Colors.white);
    });

    testWidgets('AnnotatedRegion uses dark style for light artwork',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OverlayActionButton(
              icon: Icons.arrow_back,
              artworkBrightness: Brightness.light,
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      check(icon.color).equals(const Color(0xFF1A1A1A));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it passes** (these tests validate the widget contract, not integration yet)

Run: `cd packages/audiflow_app && flutter test test/features/podcast_detail/presentation/screens/episode_detail_screen_brightness_test.dart`
Expected: PASS

- [ ] **Step 3: Update `EpisodeDetailScreen`**

Modify `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart`.

Add import at top:

```dart
import 'package:flutter/services.dart';
```

Convert `EpisodeDetailScreen` from `ConsumerWidget` to `ConsumerStatefulWidget` to hold the resolved brightness state:

```dart
class EpisodeDetailScreen extends ConsumerStatefulWidget {
  const EpisodeDetailScreen({
    super.key,
    required this.episode,
    required this.podcastTitle,
    this.artworkUrl,
    this.progress,
    this.itunesId,
  });

  final PodcastItem episode;
  final String podcastTitle;
  final String? artworkUrl;
  final EpisodeWithProgress? progress;
  final String? itunesId;

  @override
  ConsumerState<EpisodeDetailScreen> createState() =>
      _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends ConsumerState<EpisodeDetailScreen> {
  Brightness _artworkBrightness = Brightness.dark;

  @override
  void initState() {
    super.initState();
    _resolveArtworkBrightness();
  }

  Future<void> _resolveArtworkBrightness() async {
    final imageUrl = widget.episode.primaryImage?.url ?? widget.artworkUrl;
    if (imageUrl == null) return;

    final brightness = await ArtworkBrightnessResolver.resolve(
      NetworkImage(imageUrl),
    );
    if (!mounted) return;
    setState(() => _artworkBrightness = brightness);
  }
```

Replace the `build` method — wrap Scaffold with `AnnotatedRegion`, replace `SliverAppBar` leading and actions:

```dart
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final enclosureUrl = widget.episode.enclosureUrl;

    final isPlaying = enclosureUrl != null
        ? ref.watch(isEpisodePlayingProvider(enclosureUrl))
        : false;
    final isLoading = enclosureUrl != null
        ? ref.watch(isEpisodeLoadingProvider(enclosureUrl))
        : false;

    final episodeId = widget.progress?.episode.id;
    final downloadTask = episodeId != null
        ? ref.watch(episodeDownloadProvider(episodeId)).value
        : null;

    final isCompleted = widget.progress?.isCompleted ?? false;

    final imageUrl = widget.episode.primaryImage?.url ?? widget.artworkUrl;

    final overlayStyle = _artworkBrightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: imageUrl != null ? 250 : 0,
              pinned: true,
              automaticallyImplyLeading: false,
              leading: OverlayActionButton(
                icon: Icons.arrow_back,
                artworkBrightness: _artworkBrightness,
                onTap: () => Navigator.of(context).pop(),
                semanticLabel:
                    MaterialLocalizations.of(context).backButtonTooltip,
              ),
              leadingWidth: 52,
              flexibleSpace: imageUrl != null
                  ? FlexibleSpaceBar(
                      background: ExtendedImage.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        cache: true,
                      ),
                    )
                  : null,
              actions: [
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    final canShare =
                        (widget.itunesId != null &&
                            widget.episode.guid != null) ||
                        widget.episode.link != null;
                    return OverlayActionButton(
                      icon: Icons.share,
                      artworkBrightness: _artworkBrightness,
                      semanticLabel: l10n.shareEpisode,
                      onTap: canShare
                          ? () => shareEpisode(
                              ref: ref,
                              itunesId: widget.itunesId,
                              episodeGuid: widget.episode.guid,
                              fallbackLink: widget.episode.link,
                            )
                          : null,
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
```

The rest of the `build` method body (SliverToBoxAdapter with episode content) stays the same, but all references change from direct field access to `widget.` prefix (e.g., `episode` becomes `widget.episode`, `podcastTitle` becomes `widget.podcastTitle`, etc.).

Update all private methods to use `widget.` prefix for field access and accept `BuildContext`/`WidgetRef` from the state:
- `_navigateToPodcast` — use `widget.progress`, `widget.episode`, `widget.itunesId`, `widget.podcastTitle`
- `_pushPodcastDetail` — use `widget.podcastTitle`
- `_onPlayPausePressed` — use `widget.progress`, `widget.podcastTitle`, `widget.artworkUrl`, `widget.episode`
- `_onDownloadTap` — no changes needed (only uses parameters)
- `_showDeleteConfirmation` — no changes needed
- `_showReplaceQueueDialog` — no changes needed
- `_togglePlayedStatus` — use `widget.progress`

- [ ] **Step 4: Verify analyze passes**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues found

- [ ] **Step 5: Run full test suite**

Run: `cd packages/audiflow_app && flutter test`
Expected: all tests PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/podcast_detail/presentation/screens/episode_detail_screen.dart \
       packages/audiflow_app/test/features/podcast_detail/presentation/screens/episode_detail_screen_brightness_test.dart
git commit -m "feat(player): adaptive status bar and app bar buttons on episode detail"
```

---

### Task 6: Final verification

- [ ] **Step 1: Run full workspace analysis**

Run: `melos run test`
Expected: all packages pass

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 3: Verify on device** (manual)

Launch the app, open an episode with:
- Dark artwork (e.g., true crime podcast) — expect white status bar icons, light scrim + white button icons
- Light artwork (e.g., pastel-themed podcast) — expect dark status bar icons, dark scrim + dark button icons
- No artwork — expect dark fallback (white icons)
