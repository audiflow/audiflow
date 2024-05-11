// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, duplicate_ignore

part of 'connectivity_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityStateHash() => r'8e26fa18b3e148cb5e319ffecc558a7def820067';

/// See also [ConnectivityState].
@ProviderFor(ConnectivityState)
final connectivityStateProvider =
    NotifierProvider<ConnectivityState, List<ConnectivityResult>>.internal(
  ConnectivityState.new,
  name: r'connectivityStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectivityState = Notifier<List<ConnectivityResult>>;
String _$initialConnectivityStateHash() =>
    r'd68ae4ceda12363f741d87833343119f21779716';

/// See also [InitialConnectivityState].
@ProviderFor(InitialConnectivityState)
final initialConnectivityStateProvider = AsyncNotifierProvider<
    InitialConnectivityState, List<ConnectivityResult>>.internal(
  InitialConnectivityState.new,
  name: r'initialConnectivityStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialConnectivityStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InitialConnectivityState = AsyncNotifier<List<ConnectivityResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
