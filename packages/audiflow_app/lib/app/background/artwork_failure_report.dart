import '../../features/monitoring/services/failure_classification.dart';

/// Telemetry-safe description of a notification artwork failure.
///
/// Holds no error message or full URL: both can carry feed-supplied
/// credentials or tokens (CWE-532).
class ArtworkFailureReport {
  const ArtworkFailureReport({required this.url, required this.category});

  /// Scheme and host of the artwork URL.
  final String url;

  /// Error type, refined with the Dio failure type and HTTP status.
  final String category;
}

/// Report for a failure worth recording, or null for network noise
/// (timeouts, cancellations, connectivity) that is expected on poor
/// connections and not actionable.
ArtworkFailureReport? artworkFailureReport(String artworkUrl, Object error) {
  if (isExpectedFailure(error)) return null;
  return ArtworkFailureReport(
    url: sanitizeArtworkUrl(artworkUrl),
    category: errorCategory(error),
  );
}

/// [url] reduced to scheme and host; `<invalid>` when it has no host.
///
/// The path is dropped as well: signed CDN URLs can carry tokens there.
String sanitizeArtworkUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return '<invalid>';
  return Uri(scheme: uri.scheme, host: uri.host).toString();
}
