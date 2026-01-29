// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'smart_playlist_sort_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for smart playlist sort preferences.

@ProviderFor(SmartPlaylistSortController)
final smartPlaylistSortControllerProvider =
    SmartPlaylistSortControllerFamily._();

/// Controller for smart playlist sort preferences.
final class SmartPlaylistSortControllerProvider
    extends
        $NotifierProvider<
          SmartPlaylistSortController,
          SmartPlaylistSortConfig
        > {
  /// Controller for smart playlist sort preferences.
  SmartPlaylistSortControllerProvider._({
    required SmartPlaylistSortControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'smartPlaylistSortControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$smartPlaylistSortControllerHash();

  @override
  String toString() {
    return r'smartPlaylistSortControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SmartPlaylistSortController create() => SmartPlaylistSortController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SmartPlaylistSortConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SmartPlaylistSortConfig>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SmartPlaylistSortControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$smartPlaylistSortControllerHash() =>
    r'ef42e8419ec954d60cfd43cb479572446043f78e';

/// Controller for smart playlist sort preferences.

final class SmartPlaylistSortControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SmartPlaylistSortController,
          SmartPlaylistSortConfig,
          SmartPlaylistSortConfig,
          SmartPlaylistSortConfig,
          String
        > {
  SmartPlaylistSortControllerFamily._()
    : super(
        retry: null,
        name: r'smartPlaylistSortControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for smart playlist sort preferences.

  SmartPlaylistSortControllerProvider call(String podcastId) =>
      SmartPlaylistSortControllerProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'smartPlaylistSortControllerProvider';
}

/// Controller for smart playlist sort preferences.

abstract class _$SmartPlaylistSortController
    extends $Notifier<SmartPlaylistSortConfig> {
  late final _$args = ref.$arg as String;
  String get podcastId => _$args;

  SmartPlaylistSortConfig build(String podcastId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<SmartPlaylistSortConfig, SmartPlaylistSortConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SmartPlaylistSortConfig, SmartPlaylistSortConfig>,
              SmartPlaylistSortConfig,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
