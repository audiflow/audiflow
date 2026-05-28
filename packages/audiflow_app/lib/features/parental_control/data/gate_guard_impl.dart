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
    final restricted = container.read(isRestrictedModeOnProvider);
    if (!restricted) {
      return true;
    }

    // Gate is active — show the PIN entry sheet.
    if (!context.mounted) return false;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PinEntrySheet(reason: reason),
    );

    return result == true;
  }
}
