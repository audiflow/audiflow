import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/services.dart';

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

/// Unknown flavors count as prod so a misconfigured build stays quiet.
bool isDiagnosticFlavor(String? flavor) =>
    flavor == Flavor.dev.name || flavor == Flavor.stg.name;
