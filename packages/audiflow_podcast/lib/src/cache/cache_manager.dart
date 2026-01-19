import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'cache_metadata.dart';

/// Handles persistent caching logic for RSS feeds with TTL and validation.
class CacheManager {
  static const String _cacheDir = 'podcast_rss_cache';

  /// Gets the cache file for a given URL.
  Future<File> _getCacheFile(String url) async {
    final directory = await getApplicationCacheDirectory();
    final cacheFolder = Directory('${directory.path}/$_cacheDir');
    if (!await cacheFolder.exists()) {
      await cacheFolder.create(recursive: true);
    }

    final hash = _generateUrlHash(url);
    return File('${cacheFolder.path}/$hash.xml');
  }

  /// Gets the cache file by hash.
  Future<File> _getCacheFileByHash(String hash) async {
    final directory = await getApplicationCacheDirectory();
    final cacheFolder = Directory('${directory.path}/$_cacheDir');
    return File('${cacheFolder.path}/$hash.xml');
  }

  /// Gets the metadata file for a given hash.
  Future<File> _getMetadataFile(String hash) async {
    final directory = await getApplicationCacheDirectory();
    final cacheFolder = Directory('${directory.path}/$_cacheDir');
    if (!await cacheFolder.exists()) {
      await cacheFolder.create(recursive: true);
    }
    return File('${cacheFolder.path}/$hash.meta.json');
  }

  /// Gets the cache index file that tracks all cache entries.
  Future<File> _getCacheIndexFile() async {
    final directory = await getApplicationCacheDirectory();
    final cacheFolder = Directory('${directory.path}/$_cacheDir');
    if (!await cacheFolder.exists()) {
      await cacheFolder.create(recursive: true);
    }
    return File('${cacheFolder.path}/cache_index.json');
  }

  /// Generates a SHA-256 hash for the URL to use as filename.
  String _generateUrlHash(String url) {
    return sha256.convert(utf8.encode(url)).toString();
  }

  /// Checks if a cache file exists for the given URL.
  Future<bool> cacheExists(String url) async {
    final cacheFile = await _getCacheFile(url);
    return cacheFile.exists();
  }

  /// Gets the size of a cache file in bytes.
  Future<int> getCacheFileSize(String url) async {
    final cacheFile = await _getCacheFile(url);
    if (await cacheFile.exists()) {
      return cacheFile.length();
    }
    return 0;
  }

  /// Gets the total cache size in bytes.
  Future<int> getCacheSize() async {
    final directory = await getApplicationCacheDirectory();
    final cacheFolder = Directory('${directory.path}/$_cacheDir');

    if (!await cacheFolder.exists()) {
      return 0;
    }

    var totalSize = 0;
    await for (final entity in cacheFolder.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }

  /// Creates the cache directory if it doesn't exist.
  Future<void> _ensureCacheDirectoryExists() async {
    final directory = await getApplicationCacheDirectory();
    final cacheFolder = Directory('${directory.path}/$_cacheDir');
    if (!await cacheFolder.exists()) {
      await cacheFolder.create(recursive: true);
    }
  }

  /// Saves cache metadata for a given URL.
  Future<void> _saveCacheMetadata(String url, CacheMetadata metadata) async {
    await _ensureCacheDirectoryExists();
    final hash = _generateUrlHash(url);

    // Store individual metadata as JSON file
    final metadataFile = await _getMetadataFile(hash);
    await metadataFile.writeAsString(jsonEncode(metadata.toJson()));

    // Update cache index file
    await _updateCacheIndex(hash, add: true);
  }

  /// Loads cache metadata for a given URL.
  Future<CacheMetadata?> _loadCacheMetadata(String url) async {
    final hash = _generateUrlHash(url);
    final metadataFile = await _getMetadataFile(hash);

    if (!await metadataFile.exists()) {
      return null;
    }

    try {
      final metadataJson = await metadataFile.readAsString();
      final metadataMap = jsonDecode(metadataJson) as Map<String, dynamic>;
      return CacheMetadata.fromJson(metadataMap);
    } catch (e) {
      // If metadata is corrupted, return null
      return null;
    }
  }

  /// Updates the cache index file to track cache entries.
  Future<void> _updateCacheIndex(String hash, {required bool add}) async {
    final indexFile = await _getCacheIndexFile();
    var cacheIndex = <String>[];

    if (await indexFile.exists()) {
      try {
        final indexContent = await indexFile.readAsString();
        if (indexContent.isNotEmpty) {
          cacheIndex = List<String>.from(
            jsonDecode(indexContent) as Iterable<dynamic>,
          );
        }
      } catch (e) {
        // If index is corrupted, start fresh
        cacheIndex = [];
      }
    }

    if (add && !cacheIndex.contains(hash)) {
      cacheIndex.add(hash);
    } else if (!add) {
      cacheIndex.remove(hash);
    }

    await indexFile.writeAsString(jsonEncode(cacheIndex));
  }

  /// Gets all cache entry hashes from the index.
  Future<List<String>> _getCacheIndex() async {
    final indexFile = await _getCacheIndexFile();

    if (!await indexFile.exists()) {
      return [];
    }

    try {
      final indexContent = await indexFile.readAsString();
      if (indexContent.isEmpty) {
        return [];
      }
      return List<String>.from(
        jsonDecode(indexContent) as Iterable<dynamic>,
      );
    } catch (e) {
      // If index is corrupted, return empty list
      return [];
    }
  }

  /// Caches RSS feed content with metadata.
  Future<void> cacheFeed(
    String url,
    List<int> content,
    Duration ttl, {
    String? etag,
    DateTime? lastModified,
  }) async {
    await _ensureCacheDirectoryExists();

    final cacheFile = await _getCacheFile(url);
    await cacheFile.writeAsBytes(content);

    final metadata = CacheMetadata(
      cachedAt: DateTime.now(),
      ttl: ttl,
      etag: etag,
      lastModified: lastModified,
      contentLength: content.length,
    );

    await _saveCacheMetadata(url, metadata);
  }

  /// Gets cached feed content and metadata.
  Future<CachedFeed?> getCachedFeed(String url) async {
    final cacheFile = await _getCacheFile(url);

    if (!await cacheFile.exists()) {
      return null;
    }

    final metadata = await _loadCacheMetadata(url);
    if (metadata == null) {
      // Cache file exists but no metadata, consider invalid
      return null;
    }

    return CachedFeed(url: url, contentFile: cacheFile, metadata: metadata);
  }

  /// Checks if cached content is valid (exists and not expired).
  Future<bool> isCacheValid(String url) async {
    final cachedFeed = await getCachedFeed(url);
    if (cachedFeed == null) {
      return false;
    }

    return !cachedFeed.metadata.isExpired;
  }

  /// Gets all expired cache entry hashes.
  Future<List<String>> getExpiredCacheKeys() async {
    final cacheIndex = await _getCacheIndex();
    final expiredKeys = <String>[];

    for (final hash in cacheIndex) {
      final metadataFile = await _getMetadataFile(hash);
      if (await metadataFile.exists()) {
        try {
          final metadataJson = await metadataFile.readAsString();
          final metadata = CacheMetadata.fromJson(
            jsonDecode(metadataJson) as Map<String, dynamic>,
          );
          if (metadata.isExpired) {
            expiredKeys.add(hash);
          }
        } catch (e) {
          // If metadata is corrupted, consider it expired
          expiredKeys.add(hash);
        }
      } else {
        // Metadata missing, consider expired
        expiredKeys.add(hash);
      }
    }

    return expiredKeys;
  }

  /// Deletes a cache entry by hash.
  Future<void> _deleteCacheEntry(String hash) async {
    // Delete the cache file
    final cacheFile = await _getCacheFileByHash(hash);
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }

    // Delete metadata file
    final metadataFile = await _getMetadataFile(hash);
    if (await metadataFile.exists()) {
      await metadataFile.delete();
    }

    // Update cache index
    await _updateCacheIndex(hash, add: false);
  }

  /// Clears all expired cache entries.
  Future<void> clearExpiredCache() async {
    final expiredKeys = await getExpiredCacheKeys();

    for (final key in expiredKeys) {
      await _deleteCacheEntry(key);
    }
  }

  /// Clears all cache entries.
  Future<void> clearCache() async {
    final directory = await getApplicationCacheDirectory();
    final cacheFolder = Directory('${directory.path}/$_cacheDir');

    if (await cacheFolder.exists()) {
      await cacheFolder.delete(recursive: true);
    }
  }

  /// Performs maintenance cleanup with LRU eviction strategy.
  Future<void> performMaintenanceCleanup({
    int maxCacheSize = 100 * 1024 * 1024,
    int maxEntries = 1000,
  }) async {
    // First, clear expired entries
    await clearExpiredCache();

    // Check if we need to enforce size limits
    final currentSize = await getCacheSize();
    if (maxCacheSize < currentSize) {
      await _enforceMaxCacheSize(maxCacheSize);
    }

    // Check if we need to enforce entry limits
    final cacheIndex = await _getCacheIndex();
    if (maxEntries < cacheIndex.length) {
      await _enforceMaxEntries(maxEntries);
    }
  }

  /// Enforces maximum cache size by removing oldest entries.
  Future<void> _enforceMaxCacheSize(int maxSize) async {
    final cacheIndex = await _getCacheIndex();
    final entriesWithMetadata = <_CacheEntryInfo>[];

    // Collect all entries with their metadata
    for (final hash in cacheIndex) {
      final metadataFile = await _getMetadataFile(hash);
      if (await metadataFile.exists()) {
        try {
          final metadataJson = await metadataFile.readAsString();
          final metadata = CacheMetadata.fromJson(
            jsonDecode(metadataJson) as Map<String, dynamic>,
          );
          final cacheFile = await _getCacheFileByHash(hash);
          final fileSize = await cacheFile.exists()
              ? await cacheFile.length()
              : 0;

          entriesWithMetadata.add(
            _CacheEntryInfo(
              hash: hash,
              cachedAt: metadata.cachedAt,
              size: fileSize,
            ),
          );
        } catch (e) {
          // If metadata is corrupted, delete the entry
          await _deleteCacheEntry(hash);
        }
      }
    }

    // Sort by cached date (oldest first)
    entriesWithMetadata.sort((a, b) => a.cachedAt.compareTo(b.cachedAt));

    // Remove entries until we're under the size limit
    var currentSize = entriesWithMetadata.fold(
      0,
      (sum, entry) => sum + entry.size,
    );
    var index = 0;

    while (maxSize < currentSize && index < entriesWithMetadata.length) {
      final entry = entriesWithMetadata[index];
      await _deleteCacheEntry(entry.hash);
      currentSize -= entry.size;
      index++;
    }
  }

  /// Enforces maximum number of cache entries by removing oldest entries.
  Future<void> _enforceMaxEntries(int maxEntries) async {
    final cacheIndex = await _getCacheIndex();
    if (cacheIndex.length <= maxEntries) {
      return;
    }

    final entriesWithMetadata = <_CacheEntryInfo>[];

    // Collect all entries with their metadata
    for (final hash in cacheIndex) {
      final metadataFile = await _getMetadataFile(hash);
      if (await metadataFile.exists()) {
        try {
          final metadataJson = await metadataFile.readAsString();
          final metadata = CacheMetadata.fromJson(
            jsonDecode(metadataJson) as Map<String, dynamic>,
          );

          entriesWithMetadata.add(
            _CacheEntryInfo(
              hash: hash,
              cachedAt: metadata.cachedAt,
              size: 0, // Size not needed for entry count enforcement
            ),
          );
        } catch (e) {
          // If metadata is corrupted, delete the entry
          await _deleteCacheEntry(hash);
        }
      }
    }

    // Sort by cached date (oldest first)
    entriesWithMetadata.sort((a, b) => a.cachedAt.compareTo(b.cachedAt));

    // Remove oldest entries until we're under the limit
    final entriesToRemove = entriesWithMetadata.length - maxEntries;
    for (var i = 0; i < entriesToRemove; i++) {
      await _deleteCacheEntry(entriesWithMetadata[i].hash);
    }
  }
}

/// Represents a cached RSS feed with content and metadata.
class CachedFeed {
  const CachedFeed({
    required this.url,
    required this.contentFile,
    required this.metadata,
  });

  /// The original URL of the feed.
  final String url;

  /// The file containing the cached content.
  final File contentFile;

  /// The cache metadata.
  final CacheMetadata metadata;

  /// Returns a stream of the cached content.
  Stream<List<int>> getContentStream() => contentFile.openRead();

  /// Returns the cached content as bytes.
  Future<List<int>> getContentBytes() => contentFile.readAsBytes();
}

/// Internal helper class for cache entry information.
class _CacheEntryInfo {
  const _CacheEntryInfo({
    required this.hash,
    required this.cachedAt,
    required this.size,
  });
  final String hash;
  final DateTime cachedAt;
  final int size;
}
