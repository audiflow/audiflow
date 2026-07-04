import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/gate_guard.dart';
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
  bool _saving = false;

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
    if (_verifying) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _verifying = true;
      _currentErr = null;
    });
    try {
      final notifier = ref.read(parentalControlGateProvider.notifier);
      final ok = await notifier.tryUnlock(
        _current.text,
        reason: gateReasonToUnlock(GateReason.parentalSettings),
      );
      if (!mounted) return;
      if (ok) {
        setState(() {
          _verified = true;
          _verifying = false;
        });
        return;
      }
      final gateState = ref.read(parentalControlGateProvider);
      final String errorMessage;
      if (gateState is LockedOut) {
        final seconds = gateState.retryAt.difference(DateTime.now()).inSeconds;
        final safe = seconds < 1 ? 1 : seconds;
        errorMessage = l10n.parentalControlLockoutCountdown(safe);
      } else {
        final settings = await ref
            .read(parentalControlRepositoryProvider)
            .getSettings();
        if (!mounted) return;
        final remaining =
            ParentalControlPolicy.lockoutThresholdAttempts -
            settings.failedAttempts;
        final safeRemaining = remaining < 0 ? 0 : remaining;
        errorMessage = l10n.parentalControlPinIncorrect(safeRemaining);
      }
      setState(() {
        _currentErr = errorMessage;
        _verifying = false;
      });
    } catch (e, st) {
      if (!mounted) return;
      ref
          .read(namedLoggerProvider('ParentalControl'))
          .e('PIN verify failed', error: e, stackTrace: st);
      setState(() {
        _currentErr = l10n.parentalControlPinSheetError;
        _verifying = false;
      });
    }
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
                  : Text(l10n.parentalControlVerify),
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
                onPressed: (_newValid && !_saving) ? _save : null,
                child: Text(l10n.parentalControlSavePin),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
