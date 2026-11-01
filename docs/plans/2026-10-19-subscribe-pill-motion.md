# Confirm, then collapse, the podcast hero's subscribe pill

- **Status**: DONE (#715)
- **Commit**: 9c623ebb
- **Severity**: MEDIUM
- **Category**: Missed opportunities (preventing a jarring change + rare-moment delight)
- **Estimated scope**: 1 source file (~80 lines changed), 1 test file (~3 new tests)

## Problem

On podcast detail, the hero shows an accent "Subscribe" pill while the podcast
is not subscribed. When a subscribe succeeds, the pill is replaced by
`SizedBox.shrink()` in a single frame: the hero loses ~56px of height and the
sticky bar plus the whole episode list jump up. The success haptic plays, but
nothing on screen acknowledges the action; the button the user just tapped
simply vanishes under their finger.

The reverse is also abrupt: unsubscribing from the `…` menu makes the pill
pop back in and pushes the list down.

```dart
// packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/podcast_detail_header.dart:191 — current
class _SubscribeButton extends ConsumerWidget {
  ...
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subscriptionState = ref.watch(
      subscriptionControllerProvider(podcast.id),
    );

    if (subscriptionState.hasError && !subscriptionState.hasValue) {
      return _pill(context, icon: Icons.refresh, label: l10n.commonRetry, ...);
    }
    // Nothing until the state is known, so a subscribed podcast does not
    // flash a pill that then disappears.
    if (subscriptionState.value ?? true) return const SizedBox.shrink();
    return _pill(context, icon: Icons.add, label: l10n.podcastDetailSubscribe, ...);
  }
```

Subscribing happens about once per podcast, so this is rare, high-intent
moment: a short confirmation is welcome here.

## Target

Four visual states, keyed for an `AnimatedSwitcher` inside an `AnimatedSize`:

| Key | When | Renders |
| --- | --- | --- |
| `none` | state unknown, or subscribed and not confirming | `SizedBox.shrink()` |
| `retry` | `hasError && !hasValue` | existing retry pill (unchanged) |
| `offer` | settled value `false` | existing accent "Subscribe" pill (unchanged) |
| `confirmed` | for 700ms after the value settles `false -> true` | same accent pill, `Icons.check_rounded` + `l10n.podcastDetailSubscribed` ("Subscribed" / "購読中"), not tappable, colors stay accent (no disabled gray) |

Sequence on subscribe:

1. `offer -> confirmed`: crossfade, 160ms. Width settles via `AnimatedSize`.
2. Hold `confirmed` for 700ms.
3. `confirmed -> none`: the pill fades out and scales to 0.97 (160ms), then
   `AnimatedSize` closes the space (260ms). The two run back to back
   because the switcher's `Stack` keeps the old child's size until its
   out-transition ends.

Exact values (repo vocabulary, no new curves):

```dart
static const Duration _switchDuration = Duration(milliseconds: 160);
static const Duration _sizeDuration = FloatingNavigationBar.switchDuration; // 260ms
static const Duration _confirmHold = Duration(milliseconds: 700);
// AnimatedSwitcher: switchInCurve Curves.easeOutCubic, switchOutCurve Curves.easeInCubic
// transition: FadeTransition + ScaleTransition(Tween(begin: 0.97, end: 1.0))
// AnimatedSize: curve Curves.easeOutCubic, alignment Alignment.topCenter
```

Never scale below 0.97, never `scale(0)`.

Rules:

- **No animation on first appearance.** When the screen opens, the state
  resolves from loading to `false` after mount; that pill must appear
  instantly, exactly as today. Durations are `Duration.zero` until one frame
  after the first settled value has been shown.
- **Confirm only on a real transition.** Trigger `confirmed` only when the
  last *settled* value (not loading) was `false` and the new settled value
  is `true`. That covers both the pill and the `…` menu subscribe.
- **Reduced motion** (`MediaQuery.disableAnimationsOf(context)` is true): keep
  the 700ms confirmation (it is information, not decoration), drop the scale,
  use a 100ms fade, and `AnimatedSize` duration `Duration.zero`.
- Haptics are unchanged (`togglePodcastSubscription` already plays
  `HapticToken.success`).

## Repo conventions to follow

- Curves: the repo uses `Curves.easeOutCubic` for entrances and
  `Curves.easeInCubic` for exits; durations are `static const Duration`.
  Exemplar: `packages/audiflow_ui/lib/src/widgets/navigation/floating_navigation_bar.dart:65`
  (`AnimatedSwitcher` with `switchDuration`, `easeOutCubic` / `easeInCubic`,
  a `Stack` `layoutBuilder`, `KeyedSubtree` children). Reuse
  `FloatingNavigationBar.switchDuration` instead of a new 260ms literal.
- Comments explain *why*, not *what*, in the repo's terse style.
- Numeric comparisons use only `<` / `<=` (project rule).
- Tests use `package:checks` and hand-written fakes (see `_ScriptedController`
  in `test/features/podcast_detail/presentation/widgets/subscription_outcome_haptics_test.dart:32`).

## Steps

All edits in
`packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/podcast_detail_header.dart`
unless noted.

1. **Write the failing tests first** in
   `packages/audiflow_app/test/features/podcast_detail/presentation/widgets/podcast_detail_header_test.dart`.
   Override `subscriptionControllerProvider('test-id')` with a scripted
   controller (same shape as `_ScriptedController`) that starts unsubscribed
   and flips to `AsyncData(true)` on toggle. Use the phone view.
   - *confirms, then collapses*: tap the "Subscribe" pill; `pump()` +
     `pump(200ms)`; expect "Subscribed" visible. `pump(700ms)` +
     `pumpAndSettle()`; expect no `FilledButton`.
   - *no animation on first load*: pump the header, `pump()` once after the
     build future resolves; expect `tester.hasRunningAnimations` false and the
     "Subscribe" pill present.
   - *confirmed pill is not tappable*: while "Subscribed" shows, tap it; the
     toggle count on the fake stays 1.
2. Pass layout into the button: in `_buildContent(bool sideBySide)`, construct
   `_SubscribeButton(podcast: ..., subscribeSource: ..., centered: !sideBySide)`.
3. Convert `_SubscribeButton` to `ConsumerStatefulWidget` with a
   `final bool centered` field. State fields:
   ```dart
   bool? _lastSettled;          // last non-loading value seen
   bool _confirming = false;
   bool _animate = false;       // false until the first settled value was shown
   Timer? _confirmTimer;
   ```
   Cancel `_confirmTimer` in `dispose`.
4. In `build`, register the transition listener:
   ```dart
   ref.listen(subscriptionControllerProvider(widget.podcast.id), (_, next) {
     if (next.isLoading || !next.hasValue) return;
     final settled = next.requireValue;
     // Only a real unsubscribed -> subscribed change earns the confirmation.
     if (_lastSettled == false && settled) _startConfirmation();
     _lastSettled = settled;
   });
   ```
   Seed `_lastSettled` from the watched state in `build` when it is still
   null and the state has a settled value, and when that first happens
   schedule `WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _animate = true); })`.
   `_startConfirmation` sets `_confirming = true`, and starts
   `Timer(_confirmHold, () { if (mounted) setState(() => _confirming = false); })`
   (cancel any previous timer first).
5. Choose the child, keeping today's precedence:
   ```dart
   final Widget child;
   if (state.hasError && !state.hasValue) {
     child = KeyedSubtree(key: const ValueKey('retry'), child: _pill(... retry ...));
   } else if (_confirming) {
     child = KeyedSubtree(key: const ValueKey('confirmed'), child: _pill(context,
       icon: Icons.check_rounded, label: l10n.podcastDetailSubscribed, onPressed: null));
   } else if (state.value ?? true) {
     child = const SizedBox.shrink(key: ValueKey('none'));
   } else {
     child = KeyedSubtree(key: const ValueKey('offer'), child: _pill(... subscribe ...));
   }
   ```
6. In `_pill`, keep the accent look when `onPressed` is null by adding to
   `FilledButton.styleFrom`:
   `disabledBackgroundColor: colors.accent, disabledForegroundColor: colors.onAccent`.
   (The retry/offer pills are unaffected; `onPressed` is non-null for them
   except when `feedUrl == null`, which today already renders a disabled
   pill. Accept that it now shows accent instead of gray; if you think it
   should stay gray, STOP and report instead.)
7. Wrap the child:
   ```dart
   final reduceMotion = MediaQuery.disableAnimationsOf(context);
   final alignment = widget.centered ? Alignment.topCenter : AlignmentDirectional.topStart;
   return AnimatedSize(
     duration: _animate && !reduceMotion ? _sizeDuration : Duration.zero,
     curve: Curves.easeOutCubic,
     alignment: Alignment.topCenter,
     child: AnimatedSwitcher(
       duration: !_animate ? Duration.zero
           : reduceMotion ? const Duration(milliseconds: 100) : _switchDuration,
       switchInCurve: Curves.easeOutCubic,
       switchOutCurve: Curves.easeInCubic,
       layoutBuilder: (current, previous) => Stack(
         alignment: alignment,
         children: [...previous, ?current],
       ),
       transitionBuilder: (child, animation) => FadeTransition(
         opacity: animation,
         child: reduceMotion ? child : ScaleTransition(
           scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
           child: child,
         ),
       ),
       child: child,
     ),
   );
   ```
   The `Padding(top: Spacing.md)` stays inside `_pill`, so the collapse
   removes the gap too.

   **Gotcha (iOS):** `MediaQuery.disableAnimationsOf` is Android-only. iOS
   Reduce Motion arrives as
   `View.of(context).platformDispatcher.accessibilityFeatures.reduceMotion`;
   OR the two together.

   **Gotcha (first load):** the `ref.listen` callback runs before the build
   that would seed `_lastSettled`. Schedule `_animate` with its own
   `_animateScheduled` flag, not with `_lastSettled == null`. If you skip
   this, the animation never turns on.

   **Gotcha:** never give `AnimatedSize` `Duration.zero`. It asserts with
   "A RenderAnimatedSize was mutated in its own performLayout". Instead,
   return the bare child while `!_animate`, and leave out `AnimatedSize`
   (keeping the switcher) when motion is reduced.
8. Update the class doc comment on `_SubscribeButton` to say it confirms
   for a moment before leaving.

## Boundaries

- Do NOT touch `podcast_detail_screen.dart`: hero height changes already
  resync the floating navigation through the `ScrollMetricsNotification`
  listener at `podcast_detail_screen.dart:800`.
- Do NOT change `togglePodcastSubscription`, the subscription controller, or
  haptic tokens.
- Do NOT add dependencies or new l10n keys (`podcastDetailSubscribed`
  already exists in `app_en.arb` and `app_ja.arb`).
- If the code at the cited lines no longer matches (drift since 9c623ebb),
  STOP and report.

## Verification

- **Mechanical**:
  - `cd packages/audiflow_app && flutter analyze` → zero issues.
  - `flutter test test/features/podcast_detail/` → all pass, including the
    three new tests.
- **Feel check** (iPhone simulator, unsubscribed podcast from Search):
  - Tap Subscribe: the label crossfades to a check + "Subscribed" with no
    width jump; the haptic and the label change land together.
  - After ~0.7s the pill fades, *then* the space closes smoothly; the
    sticky bar glides up instead of jumping.
  - Open a podcast you're not subscribed to: the pill is simply there on
    first paint, with no grow-in.
  - Unsubscribe from `…`: the pill grows back in, with no pop.
  - Scroll the hero halfway, then subscribe from `…`: the floating nav title
    fade does not flicker while the hero shrinks.
  - Turn on Settings > Accessibility > Motion > Reduce Motion: the confirmation
    still shows; the collapse is instant, with no scaling.
  - Slow animations in Flutter DevTools (5x) and confirm the pill never
    scales below 0.97 and the text never overlaps itself mid-crossfade.
- **Done when**: tests and analyze are green, and every feel-check bullet holds on the simulator.
