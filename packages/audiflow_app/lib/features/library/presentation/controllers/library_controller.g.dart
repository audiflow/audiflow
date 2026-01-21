// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides a reactive stream of user's podcast subscriptions.
///
/// Updates automatically when subscriptions change in the database.

@ProviderFor(librarySubscriptions)
final librarySubscriptionsProvider = LibrarySubscriptionsProvider._();

/// Provides a reactive stream of user's podcast subscriptions.
///
/// Updates automatically when subscriptions change in the database.

final class LibrarySubscriptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Subscription>>,
          List<Subscription>,
          Stream<List<Subscription>>
        >
    with
        $FutureModifier<List<Subscription>>,
        $StreamProvider<List<Subscription>> {
  /// Provides a reactive stream of user's podcast subscriptions.
  ///
  /// Updates automatically when subscriptions change in the database.
  LibrarySubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'librarySubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$librarySubscriptionsHash();

  @$internal
  @override
  $StreamProviderElement<List<Subscription>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Subscription>> create(Ref ref) {
    return librarySubscriptions(ref);
  }
}

String _$librarySubscriptionsHash() =>
    r'5a727f721ac3181213f27613227a3e5599da9432';
