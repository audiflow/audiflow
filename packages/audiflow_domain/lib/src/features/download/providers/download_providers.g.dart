// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns count of downloads needing attention (failed).

@ProviderFor(downloadsNeedingAttention)
final downloadsNeedingAttentionProvider = DownloadsNeedingAttentionProvider._();

/// Returns count of downloads needing attention (failed).

final class DownloadsNeedingAttentionProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns count of downloads needing attention (failed).
  DownloadsNeedingAttentionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadsNeedingAttentionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadsNeedingAttentionHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return downloadsNeedingAttention(ref);
  }
}

String _$downloadsNeedingAttentionHash() =>
    r'79c209ea70d6a6f16cfcb5e77a607539abe0c14a';

/// Returns total storage used by downloads.

@ProviderFor(downloadStorageUsed)
final downloadStorageUsedProvider = DownloadStorageUsedProvider._();

/// Returns total storage used by downloads.

final class DownloadStorageUsedProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns total storage used by downloads.
  DownloadStorageUsedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'downloadStorageUsedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$downloadStorageUsedHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return downloadStorageUsed(ref);
  }
}

String _$downloadStorageUsedHash() =>
    r'28cfb9c1c44c1422e7a34d31c8c18ce9cdf69493';

/// Check if an episode is downloaded.

@ProviderFor(isEpisodeDownloaded)
final isEpisodeDownloadedProvider = IsEpisodeDownloadedFamily._();

/// Check if an episode is downloaded.

final class IsEpisodeDownloadedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Check if an episode is downloaded.
  IsEpisodeDownloadedProvider._({
    required IsEpisodeDownloadedFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'isEpisodeDownloadedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isEpisodeDownloadedHash();

  @override
  String toString() {
    return r'isEpisodeDownloadedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as int;
    return isEpisodeDownloaded(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsEpisodeDownloadedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isEpisodeDownloadedHash() =>
    r'b98bc6f8799f9c7c2f9a16598c517906ddb2aa4e';

/// Check if an episode is downloaded.

final class IsEpisodeDownloadedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  IsEpisodeDownloadedFamily._()
    : super(
        retry: null,
        name: r'isEpisodeDownloadedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Check if an episode is downloaded.

  IsEpisodeDownloadedProvider call(int episodeId) =>
      IsEpisodeDownloadedProvider._(argument: episodeId, from: this);

  @override
  String toString() => r'isEpisodeDownloadedProvider';
}
