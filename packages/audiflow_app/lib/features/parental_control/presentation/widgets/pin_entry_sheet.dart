import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/gate_guard.dart';

class PinEntrySheet extends ConsumerStatefulWidget {
  const PinEntrySheet({required this.reason, super.key});

  final GateReason reason;

  @override
  ConsumerState<PinEntrySheet> createState() => _PinEntrySheetState();
}

class _PinEntrySheetState extends ConsumerState<PinEntrySheet> {
  final _controller = TextEditingController();
  String? _errorMessage;
  bool _submitting = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    // Only probe when the setting is on — avoids a useless platform call on
    // every PIN sheet for users who never opted in to biometric.
    try {
      final settings = await ref
          .read(parentalControlRepositoryProvider)
          .getSettings();
      if (!settings.biometricUnlockEnabled) return;
      final available = await ref
          .read(biometricAuthenticatorProvider)
          .isAvailable();
      if (!mounted) return;
      setState(() => _biometricAvailable = available);
    } catch (e, st) {
      ref
          .read(namedLoggerProvider('ParentalControl'))
          .w(
            'PinEntrySheet biometric availability check failed',
            error: e,
            stackTrace: st,
          );
    }
  }

  Future<void> _submitBiometric() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(parentalControlGateProvider.notifier);
    try {
      final ok = await notifier.tryUnlockBiometric(
        localizedReason: l10n.parentalControlBiometricPrompt,
        reason: gateReasonToUnlock(widget.reason),
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() => _submitting = false);
    } catch (e, st) {
      ref
          .read(namedLoggerProvider('ParentalControl'))
          .e('PinEntrySheet biometric failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = l10n.parentalControlPinSheetError;
      });
    }
  }

  String _reasonHeadline(AppLocalizations l10n) {
    return switch (widget.reason) {
      GateReason.subscribe => l10n.parentalControlPinEntryReasonSubscribe,
      GateReason.unsubscribe => l10n.parentalControlPinEntryReasonUnsubscribe,
      GateReason.opmlImport => l10n.parentalControlPinEntryReasonOpmlImport,
      GateReason.deepLink => l10n.parentalControlPinEntryReasonDeepLink,
      GateReason.parentalSettings =>
        l10n.parentalControlPinEntryReasonParentalSettings,
      GateReason.developerSettings =>
        l10n.parentalControlPinEntryReasonDeveloperSettings,
      GateReason.resetData => l10n.parentalControlPinEntryReasonResetData,
    };
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final pin = _controller.text;
    final notifier = ref.read(parentalControlGateProvider.notifier);
    final l10n = AppLocalizations.of(context);

    try {
      final ok = await notifier.tryUnlock(
        pin,
        reason: gateReasonToUnlock(widget.reason),
      );
      if (!mounted) return;

      if (ok) {
        Navigator.of(context).pop(true);
        return;
      }

      final gateState = ref.read(parentalControlGateProvider);
      String errorMessage;
      if (gateState is LockedOut) {
        final seconds = gateState.retryAt.difference(DateTime.now()).inSeconds;
        // Guard against sub-second boundary producing zero or negative seconds.
        final safe = seconds < 1 ? 1 : seconds;
        errorMessage = l10n.parentalControlLockoutCountdown(safe);
      } else {
        // Compute remaining attempts from repository for accurate display.
        // One extra async repo read on wrong-PIN is acceptable for security UX.
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
        _submitting = false;
        _controller.clear();
        _errorMessage = errorMessage;
      });
    } catch (e, st) {
      ref
          .read(namedLoggerProvider('ParentalControl'))
          .e('PinEntrySheet submit failed', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _controller.clear();
        _errorMessage = l10n.parentalControlPinSheetError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _reasonHeadline(l10n),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.parentalControlPinEntryPrompt,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 8,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.parentalControlPinEntryHint,
              errorText: _errorMessage,
            ),
            onChanged: (_) => setState(() {
              _errorMessage = null;
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_biometricAvailable) ...[
                TextButton.icon(
                  onPressed: _submitting ? null : _submitBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l10n.parentalControlUseBiometric),
                ),
                const Spacer(),
              ],
              TextButton(
                // Cancel always enabled so users are never trapped.
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.parentalControlCancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (_controller.text.length < 4 || _submitting)
                    ? null
                    : _submit,
                child: Text(l10n.parentalControlSubmit),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
