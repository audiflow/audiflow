import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/services/settings/mobile_settings_service.dart';
import 'package:seasoning/services/settings/settings_service.dart';

part 'settings_service_provider.g.dart';

@riverpod
SettingsService settingsService(SettingsServiceRef ref) =>
    MobileSettingsService.instance();
