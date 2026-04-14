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

  @override
  void initState() {
    super.initState();
    _display = widget.initialValue == 0 ? '' : '${widget.initialValue}';
  }

  int get _value => int.tryParse(_display) ?? 0;

  void _appendDigit(String digit) {
    final next = _display == '0' ? digit : '$_display$digit';
    final candidate = int.tryParse(next) ?? 0;
    if (widget.maxValue < candidate) return;
    setState(() => _display = next);
  }

  void _backspace() {
    if (_display.isEmpty) return;
    setState(() => _display = _display.substring(0, _display.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
