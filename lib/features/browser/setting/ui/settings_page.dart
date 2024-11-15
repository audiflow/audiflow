import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_page.g.dart';

@riverpod
class SettingsPageController extends _$SettingsPageController {
  @override
  int build() {
    return 3;
  }

  void increment() {
    state++;
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(settingsPageControllerProvider);

    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 350,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(settingsPageControllerProvider.notifier)
                        .increment();
                  },
                  child: const Text('Increment'),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: count,
                  (context, index) {
                    return ListTile(
                      title: Text('Item $index'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
