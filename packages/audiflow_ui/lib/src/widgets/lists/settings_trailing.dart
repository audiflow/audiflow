import 'package:flutter/material.dart';

import '../../haptics/haptic_toggle.dart';
import '../../haptics/haptics_scope.dart';
import '../../themes/app_colors.dart';
import '../../themes/text_styles.dart';

/// Trailing control of a `SettingsRow` (redesign section 3.7).
///
/// Each variant owns its look and how it changes the row's tap, so the
/// row stays agnostic of which control it carries.
sealed class SettingsTrailing {
  const SettingsTrailing();

  /// Disclosure chevron for rows that open another screen.
  const factory SettingsTrailing.chevron() = _Chevron;

  /// Current value plus an up/down chevron for rows that open a picker.
  const factory SettingsTrailing.picker({required String value}) = _Picker;

  /// A switch. Tapping anywhere on the row flips it; null [onChanged]
  /// disables both. Every flip plays the toggle haptic.
  const factory SettingsTrailing.toggle({
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) = _Toggle;

  /// A -/+ stepper around [valueLabel]. Labels are the buttons'
  /// accessible names; a null callback disables that button.
  const factory SettingsTrailing.stepper({
    required String valueLabel,
    required String decrementLabel,
    required String incrementLabel,
    required VoidCallback? onDecrement,
    required VoidCallback? onIncrement,
  }) = _Stepper;

  Widget build(BuildContext context);

  /// The row's tap handler given the caller's [onTap].
  VoidCallback? rowTap(BuildContext context, VoidCallback? onTap) => onTap;

  /// Whether the row's label and this control form one semantics node.
  bool get mergesSemantics => false;
}

class _Chevron extends SettingsTrailing {
  const _Chevron();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: AppColors.of(context).inkQuaternary,
    );
  }
}

class _Picker extends SettingsTrailing {
  const _Picker({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // Bounded so a long value ellipsizes instead of squeezing the title.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(color: colors.inkSecondary),
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.unfold_more_rounded,
            size: 18,
            color: colors.inkQuaternary,
          ),
        ],
      ),
    );
  }
}

class _Toggle extends SettingsTrailing {
  const _Toggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(value: value, onChanged: _withHaptic(context));
  }

  @override
  VoidCallback? rowTap(BuildContext context, VoidCallback? onTap) {
    final handler = _withHaptic(context);
    if (handler == null) return null;
    return () => handler(!value);
  }

  ValueChanged<bool>? _withHaptic(BuildContext context) =>
      HapticsScope.of(context).toggleHaptic(onChanged);

  @override
  bool get mergesSemantics => true;
}

class _Stepper extends SettingsTrailing {
  const _Stepper({
    required this.valueLabel,
    required this.decrementLabel,
    required this.incrementLabel,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String valueLabel;
  final String decrementLabel;
  final String incrementLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = IconButton.styleFrom(
      backgroundColor: colors.surfaceMuted,
      foregroundColor: colors.ink,
      disabledBackgroundColor: colors.surfaceMuted,
      disabledForegroundColor: colors.inkQuaternary,
      minimumSize: const Size.square(44),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: decrementLabel,
          style: style,
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_rounded, size: 18),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48),
          child: Text(
            valueLabel,
            textAlign: TextAlign.center,
            style: AppTextStyles.tabular(
              AppTextStyles.body.copyWith(
                color: colors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: incrementLabel,
          style: style,
          onPressed: onIncrement,
          icon: const Icon(Icons.add_rounded, size: 18),
        ),
      ],
    );
  }
}
