// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerContextHash() => r'6775f510d3835bff5bf98aaba66e20706b627238';

/// See also [routerContext].
@ProviderFor(routerContext)
final routerContextProvider = AutoDisposeProvider<BuildContext>.internal(
  routerContext,
  name: r'routerContextProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routerContextHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RouterContextRef = AutoDisposeProviderRef<BuildContext>;
String _$appRouterHash() => r'4d9569e6b9141d4cb66607d5d6c16d5c5eda6ba5';

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
