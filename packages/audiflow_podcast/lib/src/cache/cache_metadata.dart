/// Represents cache metadata for RSS feeds.
class CacheMetadata {
  const CacheMetadata({
    required this.cachedAt,
    required this.ttl,
    this.etag,
    this.lastModified,
    required this.contentLength,
  });

  /// Creates metadata from a JSON map.
  factory CacheMetadata.fromJson(Map<String, dynamic> json) => CacheMetadata(
    cachedAt: DateTime.fromMillisecondsSinceEpoch(json['cachedAt'] as int),
    ttl: Duration(milliseconds: json['ttl'] as int),
    etag: json['etag'] as String?,
    lastModified: json['lastModified'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['lastModified'] as int)
        : null,
    contentLength: json['contentLength'] as int,
  );
  final DateTime cachedAt;
  final Duration ttl;
  final String? etag;
  final DateTime? lastModified;
  final int contentLength;

  /// Returns true if the cached content has expired.
  bool get isExpired => DateTime.now().isAfter(cachedAt.add(ttl));

  /// Converts the metadata to a JSON map.
  Map<String, dynamic> toJson() => {
    'cachedAt': cachedAt.millisecondsSinceEpoch,
    'ttl': ttl.inMilliseconds,
    'etag': etag,
    'lastModified': lastModified?.millisecondsSinceEpoch,
    'contentLength': contentLength,
  };
}
