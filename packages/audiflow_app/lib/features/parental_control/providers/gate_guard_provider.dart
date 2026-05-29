import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/gate_guard_impl.dart';
import '../domain/gate_guard.dart';

part 'gate_guard_provider.g.dart';

/// Provides the [GateGuard] singleton used throughout the app to protect
/// restricted actions behind the parental-control PIN entry sheet.
@Riverpod(keepAlive: true)
GateGuard gateGuard(Ref ref) => GateGuardImpl(container: ref.container);
