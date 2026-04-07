# Text Selection & Copy

Enable users to select and copy text across the app using context-appropriate patterns.

## Requirements

- Native text selection (long-press, drag handles, system copy menu) for long-form and title content
- One-tap copy with snackbar confirmation for short metadata fields
- Transcript selection is per-segment (does not span across segments) to preserve tap-to-seek
- No new dependencies required

## Approach: Hybrid (Scoped SelectionArea + SelectableText + CopyableText)

Three selection patterns, each applied where it fits best:

| Pattern | Use case | Behavior |
|---------|----------|----------|
| `SelectionArea` wrapper | Prose sections (descriptions, show notes) | Cross-paragraph native selection |
| `SelectableText` swap | Titles, transcript segments, standalone text | Isolated native selection per widget |
| `CopyableText` widget | Short metadata (episode number, duration, dates, stats) | Tap to copy entire value + snackbar |

## Components

### CopyableText (new widget in audiflow_ui)

```dart
CopyableText(
  text: '42',                          // value to display and copy
  snackBarMessage: l10n.commonCopiedToClipboard, // required localized message
  label: 'Episode',                    // optional leading label (not copied)
  style: TextStyle(...),
)
```

- On tap: copies `text` to clipboard via `Clipboard.setData(ClipboardData(text: value))`
- Shows snackbar with localized message (auto-dismiss ~1 second)
- Displays a small copy icon alongside the text

### SelectionArea wrappers (in audiflow_app screens)

Wrap `Html()` widget and prose sections in `SelectionArea` for cross-paragraph selection.

### SelectableText swaps (in audiflow_app screens)

Replace `Text()` with `SelectableText()` for titles and transcript segment bodies.

## Screen-by-Screen Mapping

### Episode Detail Screen

| Element | Pattern |
|---------|---------|
| Title | `SelectableText` |
| Description / show notes (HTML) | `SelectionArea` wrapping `Html()` |
| Podcast name | `Text` (tappable link, navigates to podcast) |
| Episode number | `CopyableText` |
| Duration | `CopyableText` |
| Publish date | `CopyableText` |
| Stats values (play count, completion, etc.) | `CopyableText` |

### Podcast Detail Screen

| Element | Pattern |
|---------|---------|
| Podcast title | `SelectionArea` + `Text` |
| Artist name | `SelectionArea` + `Text` |
| Description | `SelectionArea` |

### Transcript Screen

| Element | Pattern |
|---------|---------|
| Segment body text | `SelectionArea` + `Text` (per-segment tile) |
| Chapter titles | `SelectionArea` + `Text` |
| Speaker names | `SelectionArea` + `Text` |

### Player Screen

| Element | Pattern |
|---------|---------|
| Episode title | `SelectionArea` + `Text` |
| Podcast title | `SelectionArea` + `Text` |

### Out of Scope

Queue list items, search results, library subscription titles, navigation labels, button text.

## Technical Details

### flutter_html + SelectionArea

The `Html()` widget from `flutter_html` supports `SelectionArea` wrapping. Flutter's `SelectionArea` works with widgets that implement `Selectable`, and `flutter_html` renders into standard Flutter text spans. Fallback: `flutter_html` also has a `selectionEnabled` property.

### Gesture Conflict Handling (Transcript)

Transcript segments use `InkWell(onTap)` for tap-to-seek. Text inside the tile is wrapped in `SelectionArea` + `Text` (not `SelectableText`), which avoids gesture arena conflicts. `SelectionArea` enables long-press selection while leaving single-tap free for the parent `InkWell` seek gesture.

### Snackbar Feedback

`CopyableText` shows a `SnackBar` with "Copied to clipboard" on tap, auto-dismiss after ~1 second. Uses the app's existing snackbar pattern if available.

### Clipboard API

```dart
import 'package:flutter/services.dart';
Clipboard.setData(ClipboardData(text: value));
```

## Testing

| Test Type | What to verify |
|-----------|---------------|
| Unit | `CopyableText`: renders label + text, tap copies to clipboard, snackbar appears |
| Widget | Episode detail: `SelectionArea` wraps description, title is `SelectableText`, metadata is `CopyableText` |
| Widget | Podcast detail: selectable title/artist, `SelectionArea` on description |
| Widget | Transcript: segment body uses `SelectionArea` + `Text`, tap-to-seek still works |
| Integration | Clipboard contains correct value after `CopyableText` tap |

Coverage target: 80%+ for `CopyableText` widget and modified screen sections.
