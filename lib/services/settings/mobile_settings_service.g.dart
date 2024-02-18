// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_settings_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mobileSettingsServiceHash() =>
    r'c45da69ace5145cb32b356b4fa54a9763c46961f';

/// An implementation [SettingsService] for mobile devices backed by
/// shared preferences.
///
/// Copied from [MobileSettingsService].
@ProviderFor(MobileSettingsService)
final mobileSettingsServiceProvider =
    NotifierProvider<MobileSettingsService, AppSettings>.internal(
  MobileSettingsService.new,
  name: r'mobileSettingsServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mobileSettingsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MobileSettingsService = Notifier<AppSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
