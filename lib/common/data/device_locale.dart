import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_locale.g.dart';

@Riverpod(keepAlive: true)
class DeviceLocale extends _$DeviceLocale {
  @override
  Locale build() {
    return PlatformDispatcher.instance.locale;
  }

  // ignore: use_setters_to_change_properties
  void setLocale(Locale locale) {
    state = locale;
  }
}
