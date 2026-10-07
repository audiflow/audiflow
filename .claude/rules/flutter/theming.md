---
paths: **/*.dart
---
# Visual Design

Source of truth: `docs/design/redesign.md`. Follow it for tokens, components, and screen layouts.

* **Surfaces:** Warm neutral background, white grouped surfaces separated by hairlines. No background textures or gradient washes.
* **Shadows:** Grouped surfaces use a single soft 1px shadow. Floating elements (navigation buttons, mini player, menus) use a two-layer neutral shadow. Never colored or "glow" shadows.
* **Accent:** One accent color, used for primary actions, selection, links, and progress. Everything else is neutral.
* **Progress:** Show playback progress as a thin line on the bottom edge of a row or card. Do not change the shape of play controls to show progress.
* **Theme:** Define `ColorScheme` with explicit token values for light and dark (no seed color).

## Project Palette

| Token | Light | Dark |
|---|---|---|
| Background | #F7F5F2 | #141210 |
| Surface | #FFFFFF | #1F1C19 |
| Ink (text) | #1A1714 | #F3EFEA |
| Ink secondary | #5E5952 | #B8B1A8 |
| Accent | #B5531C | #F0965A |
| On accent | #FFFFFF | #1A1714 |
| Brand orange (non-text marks only) | #E8823A | #E8823A |

The full token table, contrast rules, and `ColorScheme` mapping are in `docs/design/redesign.md`.
