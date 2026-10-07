---
refs:
  id: design:redesign
  kind: design
  title: "Visual redesign specification"
  related:
    - fr:02-podcast-discovery
    - fr:04-audio-playback
    - fr:05-download-and-queue
    - fr:07-stations
    - fr:13-library
    - fr:14-settings
    - fr:17-podcast-detail
  modules:
    - packages/audiflow_ui/lib/src/themes/
    - packages/audiflow_ui/lib/src/styles/
    - packages/audiflow_ui/lib/src/widgets/
---
# Visual redesign specification

> The target look and behavior for the app's visual refresh: design tokens, shared components, and per-screen layouts. Implementation proceeds in small PRs against this document.

Design canvas (interactive mockups): https://claude.ai/artifact/GVEvGZorPjsxCBjapZji2Q

Status: **approved direction; tokens and theme (section 7 step 1) implemented, components and screens pending.** Functional Requirements under `docs/fr/` describe current behavior and are updated in the same PR that ships each change, not before.

## 1. Principles

- **Quiet surfaces, one accent.** Warm neutral ground, white content surfaces, a single burnt-orange accent. Color is reserved for state (selected, playing, progress) and primary actions.
- **Grouped lists over cards.** Related rows share one rounded white surface separated by hairlines, instead of one floating card per row.
- **Large, left-aligned titles** on top-level tabs. Detail screens use a centered or side-by-side hero that collapses on scroll.
- **Progress lives on the bottom edge.** Anything with playback progress (rows, cards, mini player) shows it as a thin line along its bottom edge. Play controls never change shape to show progress.
- **Operations vs. settings are separated.** A `…` menu holds actions; a settings sheet holds persistent per-podcast preferences.
- **No decorative effects.** No background noise texture, no colored glow shadows, no gradient washes.

## 2. Design tokens

### 2.1 Color

The palette is defined for both brightness modes. Only the light screens are designed in detail; dark mode applies the same tokens by role, with no separate layouts.

| Token | Role | Light | Dark |
|---|---|---|---|
| `bg` | Screen background | `#F7F5F2` | `#141210` |
| `surface` | Grouped lists, cards, sheets, floating buttons | `#FFFFFF` | `#1F1C19` |
| `surfaceSunken` | Segmented-control track, search field, filter field | `#ECE8E2` | `#2A2622` |
| `surfaceMuted` | Neutral pill background (play pill, menu tiles) | `#F3F0EB` | `#2A2622` |
| `ink` | Primary text and icons | `#1A1714` | `#F3EFEA` |
| `inkSecondary` | Secondary text (author, metadata) | `#5E5952` | `#B8B1A8` |
| `inkTertiary` | Captions, inactive tab labels, counts | `#6E6962` | `#9A938A` |
| `inkQuaternary` | Chevrons, drag handles, and other non-text glyphs | `#A39D95` | `#6F6961` |
| `hairline` | Row separators inside a surface | `#F0ECE6` | `#2A2622` |
| `outline` | Borders on chips and dropdown buttons | `#DED9D2` | `#3A342E` |
| `progressTrack` | Slider and standalone progress-bar track | `#E9E5DF` | `#3A342E` |
| `accent` | Primary buttons, selected tab, links, progress fill | `#B5531C` | `#F0965A` |
| `onAccent` | Text/icons on an accent fill | `#FFFFFF` | `#1A1714` |
| `accentTint` | Tonal backgrounds (subscribed pill, icon tiles, playing pill) | `accent` at 10% over `surface` (`#F8EEE8`) | `accent` at 16% over `surface` (`#403023`) |
| `brand` | Non-text brand marks only (mini player progress line) | `#E8823A` | `#E8823A` |

Contrast rules:

- `accent` must reach 4.5:1 against `surface` for text. The light value `#B5531C` gives about 5:1 on white with white text on top. The brighter `brand` orange (`#E8823A`) is about 2.7:1 with white and is **never** used behind or as text.
- Inactive text uses `inkTertiary` at minimum; `inkQuaternary` is for non-text glyphs only.

Material `ColorScheme` mapping (both modes):

| ColorScheme role | Token |
|---|---|
| `primary` / `onPrimary` | `accent` / `onAccent` |
| `primaryContainer` / `onPrimaryContainer` | `accentTint` / `accent` |
| `surface` | `bg` |
| `surfaceContainerLowest` | `surface` |
| `surfaceContainer` | `surfaceMuted` |
| `surfaceContainerHigh` | `surfaceSunken` |
| `onSurface` | `ink` |
| `onSurfaceVariant` | `inkSecondary` |
| `outline` / `outlineVariant` | `outline` / `hairline` |
| `secondary` / `tertiary` (and their `on*` / `*Container` roles) | Same as `primary` family (one accent; selected chips and segments read as the accent state) |
| `surfaceContainerLow` / `surfaceBright` | `surface` |
| `surfaceDim` | `bg` |
| `surfaceContainerHighest` | `#E4DFD8` (light) / `#332E29` (dark), one step past `surfaceSunken` |
| `inverseSurface` / `onInverseSurface` / `inversePrimary` | `ink` / `bg` / the other mode's `accent` |
| `error` family | Material 3 baseline error tones |
| `surfaceTint` | transparent (no elevation tinting) |

Component colors that the mapping alone does not settle: switch and slider tracks use `outline` and `progressTrack`; snackbars use an `ink` fill with the dark-mode accent for the action in light mode, and a `surfaceSunken` fill with `accent` in dark mode.

Replace the seed-based scheme with explicit values so the palette does not drift with the seed algorithm. In code, the full token set is the `AppColors` theme extension (`AppColors.of(context)`); `accentTint` is stored opaque so it renders the same over any ground.

### 2.2 Now Playing color

The full-screen player does not use the app palette for its ground. Its background is a dark tone derived from the current episode artwork (e.g. a desaturated, darkened dominant color), falling back to `#22304F`. All controls on it are white:

- Play/pause: white circle, glyph in the background color.
- Scrubber: white fill and thumb, white at 22% for the unplayed track.
- Secondary controls: white icons, labels white at 70%.

### 2.3 Typography

Latin text uses a geometric grotesque; Japanese uses a matching Gothic family. Weights 400/500/600/700.

| Style | Size / line-height | Weight | Use |
|---|---|---|---|
| `displayTitle` | 28 / 1.25, tracking -0.01em | 700 | Tab titles (Library, Search, Queue, Settings) |
| `heroTitle` | 21–22 / 1.35 | 700 | Podcast and series hero titles (19 when the title is long) |
| `sectionTitle` | 17 / 1.35 | 600 | Section headings inside a tab |
| `rowTitle` | 15 / 1.4 | 600 | Episode and series row titles |
| `body` | 15 / 1.4 | 400–500 | Settings rows, menu items |
| `meta` | 13 / 1.5 | 400 | Durations, counts, descriptions |
| `caption` | 12 / 1.4 | 400–600 | Dates, status labels, overlines |
| `overline` | 12–13, tracking 0.06em | 600 | Year headers, settings group headers |

Numbers that change (durations, counts, times) use tabular figures.

### 2.4 Shape, spacing, elevation

- Radii: grouped surface 18; card 16–20; artwork 10–14 (list), 16–24 (hero); pills and circular buttons fully rounded; sheet top corners 28.
- Screen side padding 20. Row padding 12–16. Gap between sections 22–30.
- Touch targets at least 44×44.
- Elevation: grouped surfaces use a 1px soft shadow only (`0 1px 2px` at 5%). Floating elements (nav buttons, mini player, menus) use a two-layer neutral shadow. No colored shadows.

## 3. Shared components

### 3.1 Bottom-edge progress line

A 3px line on the bottom edge of a row, card, or the mini player. Track `hairline`, fill `accent` (mini player uses `brand`). Hidden while unplayed; shown once playback has started, and drawn full (100%) when finished, alongside the "played" label or check.

### 3.2 Play pill

Height 32, fully rounded, `surfaceMuted` background, glyph (play / pause / check) plus a time label ("48分", "残り17分", "再生済み"). The currently playing item uses `accentTint` background with `accent` text and a pause glyph. Played items use `inkTertiary`.

### 3.3 Floating navigation

Detail screens overlay the content with:

- Left: a 44px white circular back button with the floating shadow.
- Right: a white pill grouping icon buttons. Podcast detail: [search | settings | …]. Series: [search | …].
- Center: the screen title, hidden at the top and faded in once the hero has scrolled away.
- The bar gains a `bg` background (and a hairline) only after the hero has scrolled out.

### 3.4 In-navigation search

Tapping search replaces the whole navigation row with a search field (keyboard up) and a "cancel" text button in `accent`. The hero is hidden so results start right under the navigation. The change is one motion of about 260ms: the row cross-fades with a slight horizontal drift while the hero collapses (as if scrolled away) and the bar fills; cancel plays it in reverse. The list filters as the user types; the count line reads `「query」 N 件`, and an empty state reads `「query」に一致する…はありません`. Cancel clears the query and restores the hero.

Scope follows the context: series names on the Series tab, episode titles and descriptions on the Episodes tab and on a series screen. Active filter chips still apply.

### 3.5 Mini player

A floating `surface` card (radius 16) above the tab bar: artwork 44, episode title (one line), podcast name (one line), skip-forward and play/pause buttons, and the bottom-edge progress line in `brand`. No remaining-time text.

### 3.6 Tab bar

Four tabs (Search, Library, Queue, Settings). Active tab: `accent` icon (filled variant) and label weight 600. Inactive: `inkTertiary`.

### 3.7 Grouped settings row

Row height ≥ 54 (≥ 60 with a subtitle). Optional leading 32px icon tile (`accentTint` background, `accent` glyph — one tint for all rows, not per-row colors). Trailing: chevron, current value plus up/down chevron for pickers, a switch, or a −/+ stepper.

## 4. Screens

### 4.1 Library

Top to bottom:

1. **Title** "ライブラリ" (`displayTitle`), no trailing button. Adding podcasts is the Search tab's job.
2. **Continue listening** — horizontal cards for in-progress episodes (up to 10, from playback history). Card: artwork 56, title (2 lines), remaining time, bottom-edge progress line. Section hidden when empty.
3. **Stations** — a 2-column grid showing at most 4 stations (default: most recently played). Header has a "+" (create) and "すべて表示 N" (opens the station list). The section never grows beyond 4 tiles regardless of station count.
4. **Podcasts** — sticky header row with count, sort (latest episode / subscribed date / name), and a grid/list toggle. A filter field appears under it when the library has many podcasts (threshold around 20). Grid: 3 columns, artwork with unplayed-count badge, title (2 lines). List: artwork 52, title, last-updated, unplayed badge.

### 4.2 Podcast detail

- **Hero** (centered): artwork 180, title, author and category. An `accent` filled pill "＋ 購読する" appears only while the podcast is not subscribed; a subscribed podcast shows no button, because unsubscribing lives in the `…` menu.
- **Scroll behavior**: while scrolling, the hero (artwork and text together) fades and shrinks toward its bottom edge (to about 85%), so it recedes as it goes up under the floating navigation; the navigation title fades in afterwards.
- **Sticky bar** (stays under the navigation): segmented control "エピソード / シリーズ" plus a second row that depends on the tab.
- **Series tab**: second row has the series-type dropdown (max ~58% width, ellipsized) and "↓新しい順". No series count: it crowded the dropdown into truncation. List grouped by the **start year** of each series. Row: artwork 60, name (2 lines, ellipsized), "N エピソード · 合計時間", and status text ("未再生" / "2/4 再生済み" / "再生済み" in `accent`). Started series get the bottom-edge line (full when every episode is played). Date ranges are not shown.
- **Episodes tab**: second row has filter chips "すべて / 未再生 / 再生中" and "↓新しい順"; a count line above the list. Row: date (with an `accent` dot when new), title (3 lines), description (2 lines), artwork 56 on the right, and an action row (play pill, add to queue, download, more). Played episodes fade title and artwork. Downloaded episodes show the download icon in `accent`.
- **`…` menu** (popover): top tiles "購読解除/購読する", "共有", "番組情報"; then "すべて再生済みにする", "すべて未再生にする", "再生済みを非表示"; then "ウェブサイトを開く". Subscribe/unsubscribe is reachable here so it stays available after the hero scrolls away.
- **Settings button** opens the podcast settings sheet (4.4).

### 4.3 Series episodes

- **Hero** (side by side): artwork 88, series name (up to 3 lines; one size smaller when long), podcast name (links back), "N エピソード · 合計時間", and a full-width "#n を続きから再生" button. Fades and shrinks on scroll, like the podcast hero.
- **Navigation**: floating back button and [search | …] pill; series name fades into the center after the hero is gone.
- **Sort**: a right-aligned text button "↑古い順" above the list, same style as on Podcast detail. Not sticky.
- **Rows**: episode number (`inkTertiary`), title, description (2 lines), action row with play pill and date, bottom-edge progress line once started (full when played). The playing episode's title uses `accent`.

### 4.4 Podcast settings sheet

A full-height sheet (top radius 28) with a close button and the podcast name. Groups:

1. **再生** — play order (picker).
2. **オーディオ** — "この番組専用の設定" switch; when on: skip silence, voice boost. Playback speed is not set here; it is edited only from the player's audio controls (4.5).
3. **ダウンロード** — auto-download switch; when paused, an inline `accentTint` notice with a "再開" button; keep count (picker).
4. **表示** — hide explicit episodes.

This consolidates the current settings gear sheet with the play-order and audio entries that currently live in the overflow menu.

### 4.5 Now Playing

Artwork-derived background (2.2). From top: grabber, close chevron, "Playing from" context line, overflow; artwork 342; title (2 lines) and podcast name; scrubber with elapsed/remaining; back 10 / play-pause 80 / forward 30; a translucent bar with speed, sleep timer, and output route. No "up next" or "add to queue" controls on this screen; the queue is reached from its tab.

### 4.6 Queue

Title "キュー" with a "clear" action. A now-playing card on the artwork-derived color with a white bottom-edge progress line. "Up next" grouped list: artwork 48, title (2 lines), duration and date with a downloaded indicator, and a drag handle as the only trailing control. Remove and download move to swipe actions.

### 4.7 Search

Title, search field with clear button and a store-region button beside it, a "番組 / エピソード" scope toggle, and a grouped results list.

- **番組 scope** (current behavior): artwork 60, title, author, category, a tonal "+" subscribe button. Tap opens Podcast detail.
- **エピソード scope** (new, see section 6): artwork 60, episode title (2 lines), podcast name, date and duration; the trailing control is a play pill instead of a subscribe button. Tap opens the episode detail.

Until episode search ships, the scope toggle is hidden and the screen shows podcast results only.

### 4.8 Settings

Grouped list instead of a card grid. Groups: [Appearance, Playback, Downloads, Feed sync], [Storage & data, Privacy, Parental control], [Getting started, Developer, About]. Each row: icon tile, title, one-line subtitle, chevron.

## 5. Content rules

- **Long names**: list rows clamp to 2 lines (series) or 3 lines (episode titles) with an ellipsis; hero titles clamp to 3 lines; navigation titles are one line. Full text is always reachable on the next level down.
- **Descriptions** strip decorative separator runs (e.g. long sequences of `:` or `=`) before display.
- **Dates** in series lists are omitted; progress is more useful than date ranges.

## 6. New behavior introduced by the redesign

These are not implemented today and need their own FR updates and PRs:

- Podcast `…` menu: mark all played / unplayed, hide played episodes, open website.
- Series-level progress status in the series list.
- Library: station tiles limited to 4 with a "show all" route; podcast grid/list toggle; podcast filter field; unplayed-count badges on podcasts.
- In-navigation search on Podcast detail (both tabs) and Series episodes.
- Artwork-derived Now Playing background.
- Episode search scope on the Search tab. Current discovery returns podcast metadata only, so this needs an episode-level search source before the "番組 / エピソード" toggle is shown.

## 7. Implementation order

1. Tokens and theme: `packages/audiflow_ui/lib/src/themes/` (`color_scheme.dart`, `text_styles.dart`, `app_theme.dart`) and `packages/audiflow_ui/lib/src/styles/` (`spacing.dart`, `borders.dart`).
2. Shared components in `packages/audiflow_ui/lib/src/widgets/`: progress line, play pill, floating navigation, mini player, grouped list section and settings row.
3. Screens: Library → Podcast detail (sliver-based collapsing header, sticky bar, in-nav search) → Series episodes → Now Playing → Queue → Search (podcast scope only) → Settings and the podcast settings sheet.
4. New behavior from section 6, each as a separate PR with its FR update.
