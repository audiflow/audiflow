// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effective_audio_settings_applier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Id of the podcast the now-playing episode belongs to, or null when
/// nothing is playing or the episode is not in the database.

@ProviderFor(nowPlayingPodcastId)
final nowPlayingPodcastIdProvider = NowPlayingPodcastIdProvider._();

/// Id of the podcast the now-playing episode belongs to, or null when
/// nothing is playing or the episode is not in the database.

final class NowPlayingPodcastIdProvider
    extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// Id of the podcast the now-playing episode belongs to, or null when
  /// nothing is playing or the episode is not in the database.
  NowPlayingPodcastIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowPlayingPodcastIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowPlayingPodcastIdHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return nowPlayingPodcastId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$nowPlayingPodcastIdHash() =>
    r'70065fe3173e19d7ddc137e3207b6b2130cf0f90';

/// Resolves the audio settings for [podcastId]: override -> global.
///
/// A null [podcastId] resolves to the global settings. Returns null while
/// the podcast's override is still loading, so callers never act on a
/// global value that is about to be replaced by the override. A failed
/// override load falls back to the global settings.

@ProviderFor(effectiveAudioSettings)
final effectiveAudioSettingsProvider = EffectiveAudioSettingsFamily._();

/// Resolves the audio settings for [podcastId]: override -> global.
///
/// A null [podcastId] resolves to the global settings. Returns null while
/// the podcast's override is still loading, so callers never act on a
/// global value that is about to be replaced by the override. A failed
/// override load falls back to the global settings.

final class EffectiveAudioSettingsProvider
    extends
        $FunctionalProvider<
          EffectiveAudioSettings?,
          EffectiveAudioSettings?,
          EffectiveAudioSettings?
        >
    with $Provider<EffectiveAudioSettings?> {
  /// Resolves the audio settings for [podcastId]: override -> global.
  ///
  /// A null [podcastId] resolves to the global settings. Returns null while
  /// the podcast's override is still loading, so callers never act on a
  /// global value that is about to be replaced by the override. A failed
  /// override load falls back to the global settings.
  EffectiveAudioSettingsProvider._({
    required EffectiveAudioSettingsFamily super.from,
    required int? super.argument,
  }) : super(
         retry: null,
         name: r'effectiveAudioSettingsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$effectiveAudioSettingsHash();

  @override
  String toString() {
    return r'effectiveAudioSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EffectiveAudioSettings?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EffectiveAudioSettings? create(Ref ref) {
    final argument = this.argument as int?;
    return effectiveAudioSettings(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EffectiveAudioSettings? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EffectiveAudioSettings?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveAudioSettingsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$effectiveAudioSettingsHash() =>
    r'17be5a06bb2f249fb8c98e323b5a095b0da3a771';

/// Resolves the audio settings for [podcastId]: override -> global.
///
/// A null [podcastId] resolves to the global settings. Returns null while
/// the podcast's override is still loading, so callers never act on a
/// global value that is about to be replaced by the override. A failed
/// override load falls back to the global settings.

final class EffectiveAudioSettingsFamily extends $Family
    with $FunctionalFamilyOverride<EffectiveAudioSettings?, int?> {
  EffectiveAudioSettingsFamily._()
    : super(
        retry: null,
        name: r'effectiveAudioSettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Resolves the audio settings for [podcastId]: override -> global.
  ///
  /// A null [podcastId] resolves to the global settings. Returns null while
  /// the podcast's override is still loading, so callers never act on a
  /// global value that is about to be replaced by the override. A failed
  /// override load falls back to the global settings.

  EffectiveAudioSettingsProvider call(int? podcastId) =>
      EffectiveAudioSettingsProvider._(argument: podcastId, from: this);

  @override
  String toString() => r'effectiveAudioSettingsProvider';
}

/// Effective audio settings for the now-playing podcast.

@ProviderFor(nowPlayingAudioSettings)
final nowPlayingAudioSettingsProvider = NowPlayingAudioSettingsProvider._();

/// Effective audio settings for the now-playing podcast.

final class NowPlayingAudioSettingsProvider
    extends
        $FunctionalProvider<
          EffectiveAudioSettings?,
          EffectiveAudioSettings?,
          EffectiveAudioSettings?
        >
    with $Provider<EffectiveAudioSettings?> {
  /// Effective audio settings for the now-playing podcast.
  NowPlayingAudioSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowPlayingAudioSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowPlayingAudioSettingsHash();

  @$internal
  @override
  $ProviderElement<EffectiveAudioSettings?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EffectiveAudioSettings? create(Ref ref) {
    return nowPlayingAudioSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EffectiveAudioSettings? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EffectiveAudioSettings?>(value),
    );
  }
}

String _$nowPlayingAudioSettingsHash() =>
    r'ad9774d64e34c3132f1814ef755aee54be7a9573';

/// Keeps the player on the now-playing podcast's effective settings.
///
/// Re-applies whenever the resolution changes: the now-playing podcast
/// switches, its override is switched off (back to global), or a podcast
/// override is edited from outside the player. Global edits do not reach
/// the player while an override is in effect, because the resolved value
/// does not change. Read once at startup to activate.

@ProviderFor(effectiveAudioSettingsApplier)
final effectiveAudioSettingsApplierProvider =
    EffectiveAudioSettingsApplierProvider._();

/// Keeps the player on the now-playing podcast's effective settings.
///
/// Re-applies whenever the resolution changes: the now-playing podcast
/// switches, its override is switched off (back to global), or a podcast
/// override is edited from outside the player. Global edits do not reach
/// the player while an override is in effect, because the resolved value
/// does not change. Read once at startup to activate.

final class EffectiveAudioSettingsApplierProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Keeps the player on the now-playing podcast's effective settings.
  ///
  /// Re-applies whenever the resolution changes: the now-playing podcast
  /// switches, its override is switched off (back to global), or a podcast
  /// override is edited from outside the player. Global edits do not reach
  /// the player while an override is in effect, because the resolved value
  /// does not change. Read once at startup to activate.
  EffectiveAudioSettingsApplierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveAudioSettingsApplierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveAudioSettingsApplierHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return effectiveAudioSettingsApplier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$effectiveAudioSettingsApplierHash() =>
    r'8c481c4a30a92c3bc313d625fbde9247f2f34509';
