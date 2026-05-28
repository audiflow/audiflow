import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/parental_control_controller.dart';

/// Screen for changing the parental control PIN.
///
/// The user must verify their current PIN before entering a new one.
class PinChangeScreen extends ConsumerStatefulWidget {
  const PinChangeScreen({super.key});

  @override
  ConsumerState<PinChangeScreen> createState() => _PinChangeScreenState();
}

class _PinChangeScreenState extends ConsumerState<PinChangeScreen> {
  final _current = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();

  bool _verified = false;
  String? _currentErr;
  bool _verifying = false;

  bool get _newValid {
    final n = _new1.text.length;
    return 4 <= n && n <= 8 && _new1.text == _new2.text;
  }

  @override
  void dispose() {
    _current.dispose();
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  Future<void> _verifyCurrent() async {
    setState(() {
      _verifying = true;
      _currentErr = null;
    });
    final ok = await ref
        .read(parentalControlRepositoryProvider)
        .verifyPin(_current.text);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _verified = true;
        _verifying = false;
      });
    } else {
      setState(() {
        _currentErr = 'Incorrect PIN';
        _verifying = false;
      });
    }
  }

  Future<void> _save() async {
    await ref
        .read(parentalControlControllerProvider.notifier)
        .setPin(_new1.text);
    if (!mounted) return;
    context.pop();
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
              controller: _current,
              enabled: !_verified,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.parentalControlPinCurrent,
                errorText: _currentErr,
              ),
              onChanged: (_) => setState(() => _currentErr = null),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed:
                  (!_verified && 4 <= _current.text.length && !_verifying)
                  ? _verifyCurrent
                  : null,
              child: _verifying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
            if (_verified) ...[
              const SizedBox(height: 16),
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
                onPressed: _newValid ? _save : null,
                child: Text(l10n.parentalControlSubmit),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
