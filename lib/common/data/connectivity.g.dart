// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initialConnectivityHash() =>
    r'8a7329cafc9e88b1aadcd644fe2139824b8c4e55';

/// See also [initialConnectivity].
@ProviderFor(initialConnectivity)
final initialConnectivityProvider =
    Provider<List<conn.ConnectivityResult>>.internal(
  initialConnectivity,
  name: r'initialConnectivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialConnectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InitialConnectivityRef = ProviderRef<List<conn.ConnectivityResult>>;
String _$connectivityHash() => r'bec0949a7e7af7b638529ff59a5cae9b935ff653';

/// See also [Connectivity].
@ProviderFor(Connectivity)
final connectivityProvider =
    NotifierProvider<Connectivity, List<conn.ConnectivityResult>>.internal(
  Connectivity.new,
  name: r'connectivityProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Connectivity = Notifier<List<conn.ConnectivityResult>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
