import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/services/settings/empty_settings_service.dart';
import 'package:seasoning/services/settings/settings_service.dart';

part 'settings_service_provider.g.dart';

@riverpod
SettingsService settingsService(SettingsServiceRef ref) =>
    EmptySettingsService();
