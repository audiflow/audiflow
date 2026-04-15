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
  late String _display;
  // While true, the next digit press REPLACES the readout (instead of
  // appending). Lets users open the panel with a remembered value
  // pre-filled and immediately type a fresh number without having to
  // backspace the old digits first.
  bool _isPristine = true;

  @override
  void initState() {
    super.initState();
    _display = widget.initialValue == 0 ? '' : '${widget.initialValue}';
  }

  int get _value => int.tryParse(_display) ?? 0;

  void _appendDigit(String digit) {
    final base = _isPristine || _display == '0' ? '' : _display;
    final next = '$base$digit';
    // Suppress leading zero — a number pad never shows "0" as a typed value
    // before any non-zero digit.
    if (next == '0') {
      setState(() => _isPristine = false);
      return;
    }
    final candidate = int.tryParse(next) ?? 0;
    if (widget.maxValue < candidate) return;
    setState(() {
      _display = next;
      _isPristine = false;
    });
  }

  void _backspace() {
    if (_isPristine) {
      setState(() {
        _display = '';
        _isPristine = false;
      });
      return;
    }
    if (_display.isEmpty) return;
    setState(() => _display = _display.substring(0, _display.length - 1));
  }

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
              _display.isEmpty ? '0' : _display,
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            _Keypad(onDigit: _appendDigit, onBackspace: _backspace),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _value == 0 ? null : () => widget.onStart(_value),
                child: Text(widget.startLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget digit(String d) => Expanded(
      child: TextButton(
        onPressed: () => onDigit(d),
        child: Text(d, style: Theme.of(context).textTheme.headlineMedium),
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
                icon: const Icon(Icons.backspace_outlined),
                onPressed: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
