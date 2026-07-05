import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/parental_control_controller.dart';

/// Screen for changing the parental control PIN.
///
/// Does not ask for the current PIN: while Restricted Mode is on, the entry
/// point (the Settings tile) already gates navigation behind an unlock, and
/// with the mode off the old PIN protects nothing.
class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();

  bool _saving = false;

  bool get _newValid {
    final n = _new1.text.length;
    return 4 <= n && n <= 8 && _new1.text == _new2.text;
  }

  @override
  void dispose() {
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(parentalControlControllerProvider.notifier)
          .setPin(_new1.text);
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
      appBar: AppBar(title: Text(l10n.parentalControlPinChange)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _new1,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.parentalControlPinNew,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _new2,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.parentalControlPinConfirm,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_newValid && !_saving) ? _save : null,
              child: Text(l10n.parentalControlSavePin),
            ),
          ],
        ),
      ),
    );
  }
}
