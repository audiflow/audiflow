import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// A stateful numeric input panel used inside the sleep-timer sheet.
///
/// Shows a large numeric readout, a number pad (0-9 + backspace), and a
/// primary Start button. The Start button is disabled when the current
/// value is 0.
class SleepTimerNumericPanel extends StatefulWidget {
  const SleepTimerNumericPanel({
    required this.title,
    required this.initialValue,
    required this.maxValue,
    required this.startLabel,
    required this.onBack,
    required this.onClose,
    required this.onStart,
    super.key,
  });

  final String title;
  final int initialValue;
  final int maxValue;
  final String startLabel;
  final VoidCallback onBack;
  final VoidCallback onClose;
  final ValueChanged<int> onStart;

  @override
  State<SleepTimerNumericPanel> createState() => _SleepTimerNumericPanelState();
}

class _SleepTimerNumericPanelState extends State<SleepTimerNumericPanel> {
  late NumberEntry _entry = NumberEntry.initial(widget.initialValue);

  void _appendDigit(String digit) => setState(
    () => _entry = _entry.appendDigit(digit, maxValue: widget.maxValue),
  );

  void _backspace() => setState(() => _entry = _entry.backspace());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _entry.text.isEmpty ? '0' : _entry.text,
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            NumberKeypad(onDigit: _appendDigit, onBackspace: _backspace),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _entry.value == 0
                    ? null
                    : () => widget.onStart(_entry.value),
                child: Text(widget.startLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
