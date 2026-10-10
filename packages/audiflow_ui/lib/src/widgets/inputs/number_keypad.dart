import 'package:flutter/material.dart';

/// Digits typed on a [NumberKeypad], with the keypad's editing rules.
///
/// A pre-filled value is "pristine": the first digit replaces it and the
/// first backspace clears it, so a remembered value never has to be
/// deleted digit by digit before typing a new one.
@immutable
class NumberEntry {
  const NumberEntry._(this.text, {required this.isPristine});

  /// Pre-fills [value]; 0 starts empty.
  factory NumberEntry.initial(int value) =>
      NumberEntry._(value == 0 ? '' : '$value', isPristine: true);

  final String text;
  final bool isPristine;

  int get value => int.tryParse(text) ?? 0;

  /// Appends [digit], ignoring a leading zero and anything past [maxValue].
  NumberEntry appendDigit(String digit, {required int maxValue}) {
    final base = isPristine ? '' : text;
    final next = '$base$digit';
    // A number pad never shows "0" as a typed value before another digit.
    if (next == '0') return NumberEntry._(base, isPristine: false);
    if (maxValue < (int.tryParse(next) ?? 0)) return this;
    return NumberEntry._(next, isPristine: false);
  }

  NumberEntry backspace() {
    if (isPristine) return const NumberEntry._('', isPristine: false);
    if (text.isEmpty) return this;
    return NumberEntry._(text.substring(0, text.length - 1), isPristine: false);
  }
}

/// A 3x4 number pad: digits 1-9, then 0 and backspace on the last row.
///
/// [dimmed] greys the digits without disabling them, for a pad that
/// stays tappable while another option is selected.
class NumberKeypad extends StatelessWidget {
  const NumberKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.dimmed = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = dimmed ? theme.disabledColor : null;

    Widget digit(String d) => Expanded(
      child: TextButton(
        onPressed: () => onDigit(d),
        child: Text(
          d,
          style: theme.textTheme.headlineMedium?.copyWith(color: color),
        ),
      ),
    );

    return Column(
      children: [
        Row(children: [digit('1'), digit('2'), digit('3')]),
        Row(children: [digit('4'), digit('5'), digit('6')]),
        Row(children: [digit('7'), digit('8'), digit('9')]),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            digit('0'),
            Expanded(
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: Icon(Icons.backspace_outlined, color: color),
                onPressed: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
