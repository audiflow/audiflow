// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityStateHash() => r'27c8383310a649d003c209e237b8af06abe4e7aa';

/// See also [ConnectivityState].
@ProviderFor(ConnectivityState)
final connectivityStateProvider =
    NotifierProvider<ConnectivityState, ConnectivityResult>.internal(
  ConnectivityState.new,
  name: r'connectivityStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectivityState = Notifier<ConnectivityResult>;
String _$initialConnectivityStateHash() =>
    r'2beecaf49a602fd48b0540ca6c80d9ab0c1caaa5';

/// See also [InitialConnectivityState].
@ProviderFor(InitialConnectivityState)
final initialConnectivityStateProvider = AsyncNotifierProvider<
    InitialConnectivityState, ConnectivityResult>.internal(
  InitialConnectivityState.new,
  name: r'initialConnectivityStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialConnectivityStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InitialConnectivityState = AsyncNotifier<ConnectivityResult>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
