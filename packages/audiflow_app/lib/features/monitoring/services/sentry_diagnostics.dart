import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Whether the Sentry SDK logs its own internals (`SentryOptions.debug`).
///
/// Opt-in via `--dart-define=SENTRY_DEBUG=true`, debug builds only. With
/// debug on, sentry-cocoa scans every loaded image for duplicate SDK copies
/// on a background queue, and that scan can deadlock with Dart FFI symbol
/// lookup on the iOS simulator, freezing the app on the splash screen.
const bool sentryDebugEnabled =
    kDebugMode && bool.fromEnvironment('SENTRY_DEBUG');

/// Whether investigation-only Sentry messages (boot pings, feed-sync and
/// interruption trails, background task start/finish) are sent.
///
/// These are info-level events, not failures; in prod they flood the issue
/// stream. Breadcrumbs stay on in every flavor since they only ride along
/// with real error events.
///
/// Uses Flutter's [appFlavor] rather than `FlavorConfig` because background
/// isolates never initialize `FlavorConfig`.
final bool sentryDiagnosticsEnabled = isDiagnosticFlavor(appFlavor);

/// Flavors that send the messages. Empty while paused: on dev and stg they
/// were using up the Sentry quota. Add `Flavor.dev` / `Flavor.stg` back to
/// collect them again during an investigation.
const Set<Flavor> _diagnosticFlavors = {};

/// Unknown flavors count as prod so a misconfigured build stays quiet.
bool isDiagnosticFlavor(String? flavor) =>
    _diagnosticFlavors.any((diagnostic) => diagnostic.name == flavor);
