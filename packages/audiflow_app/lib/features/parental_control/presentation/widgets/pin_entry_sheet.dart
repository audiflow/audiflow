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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    };
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final pin = _controller.text;
    final notifier = ref.read(parentalControlGateProvider.notifier);
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
    final l10n = AppLocalizations.of(context);

    if (gateState is LockedOut) {
      final seconds = gateState.retryAt.difference(DateTime.now()).inSeconds;
      // Guard against sub-second boundary producing zero or negative seconds.
      final safe = seconds < 1 ? 1 : seconds;
      setState(() {
        _submitting = false;
        _controller.clear();
        _errorMessage = l10n.parentalControlLockoutCountdown(safe);
      });
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
      // TODO: remaining-attempts counter. ParentalControlPolicy.lockoutThresholdAttempts - failedAttempts.
      // Phase 6 will expose a dedicated provider for this; repo read is the interim solution.
      final safeRemaining = remaining < 0 ? 0 : remaining;
      setState(() {
        _submitting = false;
        _controller.clear();
        _errorMessage = l10n.parentalControlPinIncorrect(safeRemaining);
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
              errorText: _errorMessage,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(false),
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
