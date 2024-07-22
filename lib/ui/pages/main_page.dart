import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/ui/controllers/scroll_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class MainPage extends ConsumerWidget {
  const MainPage({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = L10n.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            label: l10n.home,
            icon: const Icon(Symbols.home),
          ),
          NavigationDestination(
            icon: const Icon(Symbols.search),
            label: l10n.search,
          ),
          NavigationDestination(
            icon: const Icon(Symbols.video_library),
            label: l10n.library,
          ),
        ],
        onDestinationSelected: (index) async {
          final canPop = GoRouter.of(context).canPop();
          if (navigationShell.currentIndex == index && !canPop) {
            ref.read(scrollNotifierProvider.notifier).notifyScrollToTop();
          } else {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          }
        },
      ),
    );
  }
}
