import 'package:audiflow_app/features/settings/presentation/controllers/runtime_reset.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryDeviceOnlyStore implements DeviceOnlyStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void main() {
  testWidgets('a reset gives the running app a new install id', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceOnlyStoreProvider.overrideWithValue(_MemoryDeviceOnlyStore()),
      ],
    );
    addTearDown(container.dispose);

    late WidgetRef widgetRef;
    late BuildContext widgetContext;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            widgetRef = ref;
            widgetContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    final before = await tester.runAsync(
      () => container.read(installIdRepositoryProvider).getOrCreate(),
    );
    // DataResetService clears preferences, which drops the id's marker.
    await prefs.clear();

    applyRuntimeReset(widgetContext, widgetRef);
    final after = await tester.runAsync(
      () => container.read(installIdRepositoryProvider).getOrCreate(),
    );

    check(after).isNotNull().not((it) => it.equals(before!));
  });
}
