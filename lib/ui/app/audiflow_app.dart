import 'package:audiflow/core/exception/index.dart';
import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:audiflow/ui/app/themes/themes.dart';
import 'package:audiflow/ui/util/snack_bar_manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AudiflowApp extends ConsumerWidget {
  const AudiflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);

    ref.listen<AppException?>(
      appExceptionNotifierProvider,
      (_, appException) {
        if (appException != null) {
          SnackBarManager.showSnackBar(
            'An error occurred: ${appException.message}',
          );
          ref.read(appExceptionNotifierProvider.notifier).consume();
        }
      },
    );

    return MaterialApp.router(
      localizationsDelegates: const [
        ...L10n.localizationsDelegates,
      ],
      supportedLocales: const [
        ...L10n.supportedLocales,
      ],
      scaffoldMessengerKey: SnackBarManager.rootScaffoldMessengerKey,
      routerConfig: ref.watch(routerProvider).router,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: themeMode,
    );
  }
}
