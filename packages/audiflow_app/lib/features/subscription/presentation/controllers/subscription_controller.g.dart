// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing subscription state for a specific podcast.
///
/// Tracks whether the user is subscribed to a podcast identified by iTunes ID
/// and provides methods to toggle subscription status.

@ProviderFor(SubscriptionController)
final subscriptionControllerProvider = SubscriptionControllerFamily._();

/// Controller for managing subscription state for a specific podcast.
///
/// Tracks whether the user is subscribed to a podcast identified by iTunes ID
/// and provides methods to toggle subscription status.
final class SubscriptionControllerProvider
    extends $AsyncNotifierProvider<SubscriptionController, bool> {
  /// Controller for managing subscription state for a specific podcast.
  ///
  /// Tracks whether the user is subscribed to a podcast identified by iTunes ID
  /// and provides methods to toggle subscription status.
  SubscriptionControllerProvider._({
    required SubscriptionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'subscriptionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$subscriptionControllerHash();

  @override
  String toString() {
    return r'subscriptionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SubscriptionController create() => SubscriptionController();

  @override
  bool operator ==(Object other) {
    return other is SubscriptionControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subscriptionControllerHash() =>
    r'fbd8c88e70ff2e1fd6e95d0a805dab9189c9877e';

/// Controller for managing subscription state for a specific podcast.
///
/// Tracks whether the user is subscribed to a podcast identified by iTunes ID
/// and provides methods to toggle subscription status.

final class SubscriptionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SubscriptionController,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          String
        > {
  SubscriptionControllerFamily._()
    : super(
        retry: null,
        name: r'subscriptionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for managing subscription state for a specific podcast.
  ///
  /// Tracks whether the user is subscribed to a podcast identified by iTunes ID
  /// and provides methods to toggle subscription status.

  SubscriptionControllerProvider call(String itunesId) =>
      SubscriptionControllerProvider._(argument: itunesId, from: this);

  @override
  String toString() => r'subscriptionControllerProvider';
}

/// Controller for managing subscription state for a specific podcast.
///
/// Tracks whether the user is subscribed to a podcast identified by iTunes ID
/// and provides methods to toggle subscription status.

abstract class _$SubscriptionController extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as String;
  String get itunesId => _$args;

  FutureOr<bool> build(String itunesId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
