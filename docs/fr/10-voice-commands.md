---
refs:
  id: fr:10-voice-commands
  kind: fr
  title: "Voice commands (NOT IMPLEMENTED — removed)"
  related:
    - pkg:audiflow_ai
    - fr:14-settings
  modules:
    - packages/audiflow_ai/
---

# FR 10: Voice commands

> **STATUS: NOT IMPLEMENTED.** The voice-command feature was built and later removed from the codebase (see commit `5df52b76` "chore(voice): drop on-device Gemma voice command path" and follow-ups). No voice source code exists today; `packages/audiflow_ai` contains no implementation. Audiflow currently ships **without** voice commands — never describe voice control as an existing or main feature. This document is retained as a historical specification only.

> Hands-free control of playback and app settings through on-device speech recognition and a pluggable natural-language intent layer.

## Purpose

Listening to podcasts is frequently a hands-busy activity — commuting, exercising, cooking — where reaching for the screen to skip an episode or change playback speed is inconvenient or unsafe. Voice commands give the listener a hands-free way to drive the most common interactions: starting playback, pausing, skipping, navigating, searching, and adjusting preferences.

The feature is built around two distinct concerns. Playback commands ("play", "pause", "skip ahead") have a small, fixed vocabulary that a simple on-device parser handles instantly and reliably. Settings commands ("make it faster", "switch to dark mode") are fuzzy and open-ended; a user should be able to change a preference without knowing its exact name. To interpret that natural language the feature delegates to platform-native understanding — Siri App Intents on iOS, Google App Actions on Android — behind a single pluggable interface, so the heavy linguistic work is owned by the platform while audiflow keeps the business logic. All speech processing happens on-device; no audio or transcription is sent to a cloud service.

## User-visible Behavior

- **Normal case (playback)**: The listener taps the voice trigger and speaks a command. A compact floating panel anchored to the trigger appears, showing an animated audio waveform while listening. Speech-to-text transcribes the utterance on-device, the simple parser recognizes a playback command, and the action runs immediately — the panel briefly confirms success and auto-dismisses.
- **Normal case (settings)**: The listener says something like "speed up a bit" or "set the theme to dark". The simple parser finds no match, so the transcription is handed to the platform NLU layer, which resolves it to a concrete setting and value. A clear, high-confidence change is applied automatically and the panel shows the old-to-new value with an Undo button. A less certain match shows a confirmation prompt; several plausible matches show a short disambiguation list the listener taps to choose from.
- **Out-of-app case**: The listener can also invoke settings changes through "Hey Siri" / "OK Google" without opening audiflow. The platform assistant handles speech and understanding, and the resolved setting is applied directly — launching the app in the background if needed, with no in-app overlay shown.
- **Edge / failure case**: If the platform cannot match a settings command it reports "not found", and the feature then tries on-device AI to see whether the utterance was actually a non-settings command (for example playing a podcast by name). If nothing matches, or the voice subsystem is unavailable, the panel shows an error state with a hint to tap the mic and try again.
- **Recovery / fallback**: Errors are non-destructive — the panel returns to idle and the listener can simply retry. Auto-applied settings changes remain reversible through the Undo button until the panel dismisses.
- **Developer case**: On dev and staging builds only, a separate debug panel appears alongside the voice panel showing the live internal pipeline state — current recognition state, transcript, which parser matched, resolved intent, confidence, parameters, and AI readiness — so developers can diagnose recognition issues on real devices.

## Capabilities

- Recognizes a fixed vocabulary of playback and navigation commands (play, pause, skip forward/backward, navigate, search) through a fast on-device simple parser.
- Resolves fuzzy, free-form settings commands — both absolute ("set speed to 1.5") and relative ("a bit faster", "もうちょっと速く") — into concrete preference changes via platform-native NLU.
- Supports settings control for every voice-controllable preference described in a registry (theme, text scale, playback speed, skip intervals, continuous playback, play order, download and sync options, notifications, search region, language).
- Computes relative changes deterministically (step-based arithmetic with range clamping) rather than relying on the language model to do math.
- Applies confidence-based resolution: high-confidence matches auto-apply with an undo affordance, low-confidence matches ask for confirmation, multiple matches offer a disambiguation choice.
- Works both in-app (voice trigger button) and out-of-app via the platform voice assistant.
- Presents a compact, brand-styled floating voice panel with an animated waveform visualization covering all recognition states.
- Provides a developer-facing debug overlay, restricted to non-production builds, exposing the live voice pipeline state.
- Keeps all speech recognition and command interpretation on-device.

## Boundaries

- This FR covers only voice-specific behavior and the voice-controllable settings registry. The general settings screen, persistence of preferences, and the full catalog of app settings belong to FR 14 (Settings).
- The debug overlay is a developer diagnostic tool, not an end-user feature; it is rendered only on dev and staging flavors and never on production builds.
- Voice commands do not cover playback targets with dynamic vocabulary that platform NLU handles poorly (for example arbitrary podcast or episode titles) beyond what the simple parser and on-device AI fallback can match.
- The feature does not implement its own natural-language model for settings; linguistic resolution is delegated to the platform (Siri App Intents / Google App Actions). NLU accuracy is the platform's responsibility.
- No cloud LLM is involved; cloud-assisted understanding is explicitly deferred to a future feature.
- Batch setting changes from a single utterance and audio-reactive (microphone-level) waveform visualization are out of scope.
- Command execution and data access are owned by `audiflow_domain`; reusable widgets and theming by `audiflow_ui`. This FR describes the feature, not those layers' internals.

## Traceability

- **Source docs**:
  - `docs/superpowers/specs/2026-03-25-pluggable-voice-intent-design.md`
  - `docs/superpowers/plans/2026-03-25-pluggable-voice-intent.md`
  - `docs/superpowers/specs/2026-03-24-voice-settings-design.md`
  - `docs/superpowers/plans/2026-03-24-voice-settings.md`
  - `docs/superpowers/specs/2026-03-29-voice-ui-redesign.md`
  - `docs/superpowers/plans/2026-03-29-voice-ui-redesign.md`
  - `docs/superpowers/specs/2026-03-30-voice-debug-overlay-design.md`
  - `docs/superpowers/plans/2026-03-30-voice-debug-overlay.md`
- **Related FR**: 14-settings.md
- **Note**: The voice-command feature was implemented and subsequently **removed** from the codebase; no voice source code remains in any package. The `audiflow_ai` package directory exists but holds no implementation. This FR is kept solely as the historical specification in case the feature is ever revisited. Any statement that audiflow "has" or "provides" voice commands is incorrect.
