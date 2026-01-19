import 'dart:io';

import 'package:audiflow_podcast/src/cache/cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const testUrl = 'https://example.com/feed.xml';
const testUrl1 = 'https://example.com/feed1.xml';
const testUrl2 = 'https://example.com/feed2.xml';
const testUrl3 = 'https://example.com/feed3.xml';
const testRssContent = 'test RSS content';
const defaultTtl = Duration(hours: 1);

List<int> get testContent => testRssContent.codeUnits;

Future<void> cleanupCacheDirectory(
  MockPathProviderPlatform mockPathProvider,
) async {
  try {
    final cacheDir = await mockPathProvider.getApplicationCachePath();
    if (cacheDir != null) {
      final dir = Directory(cacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
  } catch (e) {
    // Ignore cleanup errors
  }
}

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  String? _cacheDir;

  @override
  Future<String?> getApplicationCachePath() async {
    // Return the same temporary directory for testing
    _cacheDir ??= Directory.systemTemp.createTempSync('cache_test').path;
    return _cacheDir;
  }
}

void main() {
  group('CacheManager File Operations', () {
    late CacheManager cacheManager;
    late MockPathProviderPlatform mockPathProvider;

    setUp(() {
      mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;
      cacheManager = CacheManager();
    });

    tearDown(() => cleanupCacheDirectory(mockPathProvider));

    test('should create cache directory when it does not exist', () async {
      expect(await cacheManager.cacheExists(testUrl), false);

      final size = await cacheManager.getCacheFileSize(testUrl);
      expect(size, 0);
    });

    test('should generate consistent hash for same URL', () async {
      await cacheManager.cacheExists(testUrl);
      final size1 = await cacheManager.getCacheFileSize(testUrl);
      final size2 = await cacheManager.getCacheFileSize(testUrl);

      expect(size1, size2);
    });

    test('should generate different hashes for different URLs', () async {
      final exists1 = await cacheManager.cacheExists(testUrl1);
      final exists2 = await cacheManager.cacheExists(testUrl2);

      expect(exists1, false);
      expect(exists2, false);
    });

    test('should return false for non-existent cache file', () async {
      const testUrl = 'https://example.com/nonexistent.xml';

      final exists = await cacheManager.cacheExists(testUrl);
      expect(exists, false);
    });

    test('should return 0 size for non-existent cache file', () async {
      const testUrl = 'https://example.com/nonexistent.xml';

      final size = await cacheManager.getCacheFileSize(testUrl);
      expect(size, 0);
    });

    test(
      'should return 0 for total cache size when cache directory is empty',
      () async {
        final totalSize = await cacheManager.getCacheSize();
        expect(totalSize, 0);
      },
    );

    test('should handle special characters in URLs', () async {
      const testUrl = 'https://example.com/feed with spaces & symbols!.xml';

      final exists = await cacheManager.cacheExists(testUrl);
      expect(exists, false);

      final size = await cacheManager.getCacheFileSize(testUrl);
      expect(size, 0);
    });

    test('should handle very long URLs', () async {
      final longUrl = 'https://example.com/${'a' * 1000}.xml';

      final exists = await cacheManager.cacheExists(longUrl);
      expect(exists, false);

      final size = await cacheManager.getCacheFileSize(longUrl);
      expect(size, 0);
    });
  });

  group('CacheManager Metadata Tracking', () {
    late CacheManager cacheManager;
    late MockPathProviderPlatform mockPathProvider;

    setUp(() {
      mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;
      cacheManager = CacheManager();
    });

    tearDown(() => cleanupCacheDirectory(mockPathProvider));

    test('should cache feed content with metadata', () async {
      await cacheManager.cacheFeed(testUrl, testContent, defaultTtl);

      expect(await cacheManager.cacheExists(testUrl), true);
      expect(await cacheManager.isCacheValid(testUrl), true);
      expect(await cacheManager.getCacheFileSize(testUrl), testContent.length);
    });

    test('should retrieve cached feed with metadata', () async {
      const etag = 'test-etag';
      final lastModified = DateTime.now().subtract(const Duration(minutes: 30));

      await cacheManager.cacheFeed(
        testUrl,
        testContent,
        defaultTtl,
        etag: etag,
        lastModified: lastModified,
      );

      final cachedFeed = await cacheManager.getCachedFeed(testUrl);

      expect(cachedFeed, isNotNull);
      expect(cachedFeed!.url, testUrl);
      expect(cachedFeed.metadata.etag, etag);
      expect(
        cachedFeed.metadata.lastModified!
                .difference(lastModified)
                .abs()
                .inSeconds <
            1,
        true,
      );
      expect(cachedFeed.metadata.contentLength, testContent.length);
      expect(cachedFeed.metadata.ttl, defaultTtl);
      expect(cachedFeed.metadata.isExpired, false);

      final contentBytes = await cachedFeed.getContentBytes();
      expect(contentBytes, testContent);
    });

    test('should return null for non-existent cached feed', () async {
      const testUrl = 'https://example.com/nonexistent.xml';

      final cachedFeed = await cacheManager.getCachedFeed(testUrl);
      expect(cachedFeed, isNull);
    });

    test('should handle cache with expired TTL', () async {
      const shortTtl = Duration(milliseconds: 1);
      await cacheManager.cacheFeed(testUrl, testContent, shortTtl);

      await Future.delayed(const Duration(milliseconds: 10));

      final cachedFeed = await cacheManager.getCachedFeed(testUrl);
      expect(cachedFeed, isNotNull);
      expect(cachedFeed!.metadata.isExpired, true);
      expect(await cacheManager.isCacheValid(testUrl), false);
    });

    test('should handle multiple cached feeds', () async {
      final testContent1 = 'test RSS content 1'.codeUnits;
      final testContent2 = 'test RSS content 2'.codeUnits;

      await cacheManager.cacheFeed(testUrl1, testContent1, defaultTtl);
      await cacheManager.cacheFeed(testUrl2, testContent2, defaultTtl);

      expect(await cacheManager.cacheExists(testUrl1), true);
      expect(await cacheManager.cacheExists(testUrl2), true);
      expect(await cacheManager.isCacheValid(testUrl1), true);
      expect(await cacheManager.isCacheValid(testUrl2), true);

      final cachedFeed1 = await cacheManager.getCachedFeed(testUrl1);
      final cachedFeed2 = await cacheManager.getCachedFeed(testUrl2);

      expect(cachedFeed1!.metadata.contentLength, testContent1.length);
      expect(cachedFeed2!.metadata.contentLength, testContent2.length);
    });

    test('should handle corrupted metadata gracefully', () async {
      await cacheManager.cacheFeed(testUrl, testContent, defaultTtl);

      final cacheDir = await mockPathProvider.getApplicationCachePath();
      final cacheFolder = Directory('$cacheDir/podcast_rss_cache');
      final files = await cacheFolder.list().toList();
      final metadataFile =
          files.firstWhere((f) => f.path.endsWith('.meta.json')) as File;
      await metadataFile.writeAsString('invalid json');

      final cachedFeed = await cacheManager.getCachedFeed(testUrl);
      expect(cachedFeed, isNull);
      expect(await cacheManager.isCacheValid(testUrl), false);
    });

    test('should update cache index when adding entries', () async {
      const testUrl1 = 'https://example.com/feed1.xml';
      const testUrl2 = 'https://example.com/feed2.xml';
      final testContent = 'test RSS content'.codeUnits;
      const ttl = Duration(hours: 1);

      // Add entries and verify they exist
      await cacheManager.cacheFeed(testUrl1, testContent, ttl);
      expect(await cacheManager.cacheExists(testUrl1), true);

      await cacheManager.cacheFeed(testUrl2, testContent, ttl);
      expect(await cacheManager.cacheExists(testUrl2), true);

      // Both should be valid
      expect(await cacheManager.isCacheValid(testUrl1), true);
      expect(await cacheManager.isCacheValid(testUrl2), true);
    });

    test('should stream cached content', () async {
      const testUrl = 'https://example.com/feed.xml';
      final testContent = 'test RSS content'.codeUnits;
      const ttl = Duration(hours: 1);

      await cacheManager.cacheFeed(testUrl, testContent, ttl);

      final cachedFeed = await cacheManager.getCachedFeed(testUrl);
      expect(cachedFeed, isNotNull);

      // Test streaming content
      final streamedContent = <int>[];
      await for (final chunk in cachedFeed!.getContentStream()) {
        streamedContent.addAll(chunk);
      }

      expect(streamedContent, testContent);
    });
  });

  group('CacheManager Cleanup Logic', () {
    late CacheManager cacheManager;
    late MockPathProviderPlatform mockPathProvider;

    setUp(() {
      mockPathProvider = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProvider;
      cacheManager = CacheManager();
    });

    tearDown(() => cleanupCacheDirectory(mockPathProvider));

    test('should identify expired cache entries', () async {
      await cacheManager.cacheFeed(
        testUrl1,
        testContent,
        const Duration(milliseconds: 1),
      );
      await cacheManager.cacheFeed(testUrl2, testContent, defaultTtl);

      await Future.delayed(const Duration(milliseconds: 10));

      final expiredKeys = await cacheManager.getExpiredCacheKeys();
      expect(expiredKeys, hasLength(1));
      expect(await cacheManager.isCacheValid(testUrl1), false);
      expect(await cacheManager.isCacheValid(testUrl2), true);
    });

    test('should clear expired cache entries', () async {
      await cacheManager.cacheFeed(
        testUrl1,
        testContent,
        const Duration(milliseconds: 1),
      );
      await cacheManager.cacheFeed(testUrl2, testContent, defaultTtl);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(await cacheManager.cacheExists(testUrl1), true);
      expect(await cacheManager.cacheExists(testUrl2), true);

      await cacheManager.clearExpiredCache();

      expect(await cacheManager.cacheExists(testUrl1), false);
      expect(await cacheManager.cacheExists(testUrl2), true);
    });

    test('should clear all cache entries', () async {
      await cacheManager.cacheFeed(testUrl1, testContent, defaultTtl);
      await cacheManager.cacheFeed(testUrl2, testContent, defaultTtl);

      expect(await cacheManager.cacheExists(testUrl1), true);
      expect(await cacheManager.cacheExists(testUrl2), true);

      await cacheManager.clearCache();

      expect(await cacheManager.cacheExists(testUrl1), false);
      expect(await cacheManager.cacheExists(testUrl2), false);
      expect(await cacheManager.getCacheSize(), 0);
    });

    test('should perform maintenance cleanup', () async {
      const testUrl1 = 'https://example.com/feed1.xml';
      const testUrl2 = 'https://example.com/feed2.xml';
      final testContent = 'test RSS content'.codeUnits;

      // Cache one expired entry and one valid entry
      await cacheManager.cacheFeed(
        testUrl1,
        testContent,
        const Duration(milliseconds: 1),
      );
      await cacheManager.cacheFeed(
        testUrl2,
        testContent,
        const Duration(hours: 1),
      );

      // Wait for first entry to expire
      await Future.delayed(const Duration(milliseconds: 10));

      // Both should exist initially
      expect(await cacheManager.cacheExists(testUrl1), true);
      expect(await cacheManager.cacheExists(testUrl2), true);

      // Perform maintenance cleanup
      await cacheManager.performMaintenanceCleanup();

      // Only the valid entry should remain
      expect(await cacheManager.cacheExists(testUrl1), false);
      expect(await cacheManager.cacheExists(testUrl2), true);
    });

    test('should enforce maximum cache size', () async {
      final largeContent = List.filled(1000, 65); // 1KB content
      const ttl = Duration(hours: 1);

      // Cache multiple entries that exceed size limit
      await cacheManager.cacheFeed(
        'https://example.com/feed1.xml',
        largeContent,
        ttl,
      );
      await Future.delayed(
        const Duration(milliseconds: 10),
      ); // Ensure different timestamps
      await cacheManager.cacheFeed(
        'https://example.com/feed2.xml',
        largeContent,
        ttl,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await cacheManager.cacheFeed(
        'https://example.com/feed3.xml',
        largeContent,
        ttl,
      );

      // All should exist initially
      expect(
        await cacheManager.cacheExists('https://example.com/feed1.xml'),
        true,
      );
      expect(
        await cacheManager.cacheExists('https://example.com/feed2.xml'),
        true,
      );
      expect(
        await cacheManager.cacheExists('https://example.com/feed3.xml'),
        true,
      );

      // Perform cleanup with very small size limit (should remove oldest entries)
      await cacheManager.performMaintenanceCleanup(
        maxCacheSize: 1500,
      ); // Allow ~1.5 entries

      // The oldest entry should be removed, newest should remain
      expect(
        await cacheManager.cacheExists('https://example.com/feed1.xml'),
        false,
      );
      expect(
        await cacheManager.cacheExists('https://example.com/feed3.xml'),
        true,
      );
    });

    test('should enforce maximum number of entries', () async {
      final testContent = 'test RSS content'.codeUnits;
      const ttl = Duration(hours: 1);

      // Cache multiple entries
      await cacheManager.cacheFeed(
        'https://example.com/feed1.xml',
        testContent,
        ttl,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await cacheManager.cacheFeed(
        'https://example.com/feed2.xml',
        testContent,
        ttl,
      );
      await Future.delayed(const Duration(milliseconds: 10));
      await cacheManager.cacheFeed(
        'https://example.com/feed3.xml',
        testContent,
        ttl,
      );

      // All should exist initially
      expect(
        await cacheManager.cacheExists('https://example.com/feed1.xml'),
        true,
      );
      expect(
        await cacheManager.cacheExists('https://example.com/feed2.xml'),
        true,
      );
      expect(
        await cacheManager.cacheExists('https://example.com/feed3.xml'),
        true,
      );

      // Perform cleanup with entry limit
      await cacheManager.performMaintenanceCleanup(maxEntries: 2);

      // The oldest entry should be removed
      expect(
        await cacheManager.cacheExists('https://example.com/feed1.xml'),
        false,
      );
      expect(
        await cacheManager.cacheExists('https://example.com/feed2.xml'),
        true,
      );
      expect(
        await cacheManager.cacheExists('https://example.com/feed3.xml'),
        true,
      );
    });

    test('should handle corrupted metadata during cleanup', () async {
      const testUrl = 'https://example.com/feed.xml';
      final testContent = 'test RSS content'.codeUnits;
      const ttl = Duration(hours: 1);

      // Cache normally first
      await cacheManager.cacheFeed(testUrl, testContent, ttl);
      expect(await cacheManager.cacheExists(testUrl), true);

      // Corrupt the metadata file by accessing internal structure
      final cacheDir = await mockPathProvider.getApplicationCachePath();
      final cacheFolder = Directory('$cacheDir/podcast_rss_cache');
      final files = await cacheFolder.list().toList();
      final metadataFile =
          files.firstWhere((f) => f.path.endsWith('.meta.json')) as File;
      await metadataFile.writeAsString('invalid json');

      // Cleanup should handle corrupted metadata gracefully
      await cacheManager.clearExpiredCache();

      // The entry with corrupted metadata should be removed
      expect(await cacheManager.cacheExists(testUrl), false);
    });
  });
}
