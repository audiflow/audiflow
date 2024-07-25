// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rooterContextHash() => r'7b50a2de2b8aa6c8c7a7c8c234138e1edb7c82ea';

/// See also [rooterContext].
@ProviderFor(rooterContext)
final rooterContextProvider = AutoDisposeProvider<BuildContext>.internal(
  rooterContext,
  name: r'rooterContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rooterContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RooterContextRef = AutoDisposeProviderRef<BuildContext>;
String _$appRouterHash() => r'ef9a8ed1b00a98feff8a4e5547d28476e5faa54e';

/// See also [AppRouter].
@ProviderFor(AppRouter)
final appRouterProvider = NotifierProvider<AppRouter, GoRouter>.internal(
  AppRouter.new,
  name: r'appRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppRouter = Notifier<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
