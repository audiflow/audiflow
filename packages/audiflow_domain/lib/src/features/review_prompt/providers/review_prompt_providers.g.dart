// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_prompt_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviewPromptRepository)
final reviewPromptRepositoryProvider = ReviewPromptRepositoryProvider._();

final class ReviewPromptRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewPromptRepository,
          ReviewPromptRepository,
          ReviewPromptRepository
        >
    with $Provider<ReviewPromptRepository> {
  ReviewPromptRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewPromptRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewPromptRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewPromptRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewPromptRepository create(Ref ref) {
    return reviewPromptRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewPromptRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewPromptRepository>(value),
    );
  }
}

String _$reviewPromptRepositoryHash() =>
    r'3f70ad3d0597096aafa3f381c7b6508669f96827';

@ProviderFor(reviewPromptTrigger)
final reviewPromptTriggerProvider = ReviewPromptTriggerProvider._();

final class ReviewPromptTriggerProvider
    extends
        $FunctionalProvider<
          ReviewPromptTrigger,
          ReviewPromptTrigger,
          ReviewPromptTrigger
        >
    with $Provider<ReviewPromptTrigger> {
  ReviewPromptTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewPromptTriggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewPromptTriggerHash();

  @$internal
  @override
  $ProviderElement<ReviewPromptTrigger> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReviewPromptTrigger create(Ref ref) {
    return reviewPromptTrigger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewPromptTrigger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewPromptTrigger>(value),
    );
  }
}

String _$reviewPromptTriggerHash() =>
    r'67bfb74fa7c89e9fcb933471377b15b386a19a3b';

/// Stream of "prompt-ready" events. Consumers are responsible for
/// foreground gating; this stream fires regardless of app state.

@ProviderFor(reviewPromptTriggerEvents)
final reviewPromptTriggerEventsProvider = ReviewPromptTriggerEventsProvider._();

/// Stream of "prompt-ready" events. Consumers are responsible for
/// foreground gating; this stream fires regardless of app state.

final class ReviewPromptTriggerEventsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, Stream<void>>
    with $FutureModifier<void>, $StreamProvider<void> {
  /// Stream of "prompt-ready" events. Consumers are responsible for
  /// foreground gating; this stream fires regardless of app state.
  ReviewPromptTriggerEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewPromptTriggerEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewPromptTriggerEventsHash();

  @$internal
  @override
  $StreamProviderElement<void> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<void> create(Ref ref) {
    return reviewPromptTriggerEvents(ref);
  }
}

String _$reviewPromptTriggerEventsHash() =>
    r'd972cb7b9ef3feb4da9753a78e6b22971a8036e2';
