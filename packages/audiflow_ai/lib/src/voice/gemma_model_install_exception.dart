import 'package:flutter/foundation.dart';

import 'gemma_model_variant.dart';

/// Phase of `GemmaModelManager.ensureInstalled` in which an install failed.
///
/// Lets callers distinguish credential problems from network/disk failures
/// when rendering recovery UI.
enum GemmaModelInstallPhase {
  /// The injected auth-token resolver threw before any download started.
  authTokenResolution,

  /// The underlying plugin's `installFromNetwork` call failed.
  download,
}

/// Typed wrapper around any error thrown while installing a Gemma model.
///
/// `GemmaModelManager.ensureInstalled` catches errors from the auth-token
/// resolver and the plugin's network install and rethrows them as this
/// exception so callers can switch on [phase] and [variant] without
/// inspecting raw plugin / IO exception types.
@immutable
final class GemmaModelInstallException implements Exception {
  const GemmaModelInstallException({
    required this.variant,
    required this.phase,
    required this.cause,
    required this.stackTrace,
  });

  /// The variant the manager was trying to install.
  final GemmaModelVariant variant;

  /// Which step of the install pipeline failed.
  final GemmaModelInstallPhase phase;

  /// The original error from the underlying API.
  final Object cause;

  /// The original stack trace, propagated for crash-report fidelity.
  final StackTrace stackTrace;

  @override
  String toString() =>
      'GemmaModelInstallException(variant: ${variant.name}, '
      'phase: ${phase.name}, cause: $cause)';
}
