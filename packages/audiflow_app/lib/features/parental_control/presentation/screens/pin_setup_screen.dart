import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/parental_control_controller.dart';

/// Screen for setting up the parental control PIN for the first time.
class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  String? _err;
  bool _saving = false;

  bool get _valid {
    final n = _pin1.text.length;
    return 4 <= n && n <= 8 && _pin1.text == _pin2.text;
  }

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(parentalControlControllerProvider.notifier)
          .setPin(_pin1.text);
      if (!mounted) return;
      context.pop();
    } catch (e, st) {
      if (!mounted) return;
      ref
          .read(namedLoggerProvider('ParentalControl'))
          .e('setPin failed', error: e, stackTrace: st);
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.parentalControlSettingsSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.parentalControlPinSetupTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.parentalControlPinSetupSubtitle),
            const SizedBox(height: 16),
            TextField(
              controller: _pin1,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (_) => setState(() => _err = null),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pin2,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.parentalControlPinConfirm,
                errorText: _err,
              ),
              onChanged: (_) => setState(() => _err = null),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_valid && !_saving) ? _save : null,
              child: Text(l10n.parentalControlSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
