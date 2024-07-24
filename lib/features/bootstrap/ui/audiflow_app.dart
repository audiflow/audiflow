import 'package:audiflow/constants/color_schemes.g.dart';
import 'package:audiflow/core/exception/index.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:audiflow/localization/string_hardcoded.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:audiflow/ui/util/snack_bar_manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AudiflowApp extends ConsumerWidget {
  const AudiflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(appPreferenceRepositoryProvider.select((pref) => pref.theme));
    final router = ref.watch(appRouterProvider);

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
      routerConfig: router,
      restorationScopeId: 'app',
      onGenerateTitle: (BuildContext context) => 'audiflow'.hardcoded,
      localizationsDelegates: const [
        ...L10n.localizationsDelegates,
      ],
      supportedLocales: const [
        ...L10n.supportedLocales,
      ],
      scaffoldMessengerKey: SnackBarManager.rootScaffoldMessengerKey,
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: themeMode,
    );
  }
}
