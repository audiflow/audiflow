import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/gate_guard.dart';
import '../presentation/widgets/pin_entry_sheet.dart';

/// Concrete [GateGuard] that reads [isRestrictedModeOnProvider] and shows
/// [PinEntrySheet] when a PIN challenge is required.
///
/// Inject a [ProviderContainer] (from [ProviderScope.containerOf]) so the
/// guard can read Riverpod state without holding a stale [BuildContext].
class GateGuardImpl implements GateGuard {
  const GateGuardImpl({required this.container});

  final ProviderContainer container;

  @override
  Future<bool> requireUnlock(
    BuildContext context, {
    required GateReason reason,
  }) async {
    final bool restricted;
    try {
      restricted = container.read(isRestrictedModeOnProvider);
    } catch (e, st) {
      container
          .read(namedLoggerProvider('ParentalControl'))
          .e(
            'requireUnlock: isRestrictedModeOn read failed; failing closed',
            error: e,
            stackTrace: st,
          );
      return false; // fail closed
    }
    if (!restricted) return true;

    final state = container.read(parentalControlGateProvider);
    if (state is Unlocked) {
      container.read(parentalControlGateProvider.notifier).extendIdle();
      return true;
    }

    if (!context.mounted) return false;

    try {
      final result = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        builder: (_) => PinEntrySheet(reason: reason),
      );
      return result == true;
    } catch (e, st) {
      container
          .read(namedLoggerProvider('ParentalControl'))
          .e(
            'requireUnlock: PIN entry sheet failed to present',
            error: e,
            stackTrace: st,
          );
      return false; // fail closed on sheet failure
    }
  }
}
