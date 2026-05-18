import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_opt_in_controller.g.dart';

const _kKey = 'analytics.opt_in';

@Riverpod(keepAlive: true)
class AnalyticsOptInController extends _$AnalyticsOptInController {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_kKey) ?? true;
  }

  Future<void> setOptIn(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_kKey, value);
    await ref.read(analyticsServiceProvider).setOptIn(value);
    state = value;
  }
}
