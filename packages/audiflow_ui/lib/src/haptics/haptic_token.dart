/// A haptic the app may play, named by what it means.
///
/// This is the catalog in `docs/design/haptics.md`. Each platform maps a
/// token to its own pattern natively, so the [name] of every value is the
/// platform channel contract and must not change.
enum HapticToken {
  /// One discrete option became selected.
  selection(playsInReducedMode: false),

  /// A switch turned on.
  toggleOn(playsInReducedMode: false),

  /// A switch turned off.
  toggleOff(playsInReducedMode: false),

  /// A low-key action was accepted, where the result is not otherwise felt.
  tap(playsInReducedMode: false),

  /// A long press reached its activation time.
  longPress(playsInReducedMode: false),

  /// A drag passed the point where releasing triggers an action.
  thresholdCross(playsInReducedMode: true),

  /// A drag moved back below that point, cancelling the action.
  thresholdRelease(playsInReducedMode: true),

  /// A reorderable item was picked up.
  dragPickUp(playsInReducedMode: true),

  /// A dragged item moved past a neighbor.
  dragStep(playsInReducedMode: false),

  /// A dragged item was put down.
  dragDrop(playsInReducedMode: false),

  /// A continuous gesture passed a meaningful mark.
  detent(playsInReducedMode: false),

  /// A user-initiated task completed.
  success(playsInReducedMode: true),

  /// A confirmation for an irreversible action appeared.
  warning(playsInReducedMode: true),

  /// A user-initiated task failed.
  error(playsInReducedMode: true);

  const HapticToken({required this.playsInReducedMode});

  /// Whether the token still plays when the user chose Reduced haptics.
  ///
  /// Reduced mode keeps outcomes and feedback the user cannot see well
  /// while a finger covers the control; it drops what is obvious on screen.
  final bool playsInReducedMode;
}
