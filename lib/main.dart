// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:audiflow/api/podcast/podcast_api_provider.dart';
import 'package:audiflow/repository/download_event.dart';
import 'package:audiflow/repository/episode_event.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/repository/transcript_event.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/services/audio/audio_position_saver.dart';
import 'package:audiflow/services/audio/audio_queue_manager.dart';
import 'package:audiflow/services/audio/mobile_audio_player_service.dart';
import 'package:audiflow/services/connectivity/connectivity_state.dart';
import 'package:audiflow/services/download/download_manager_provider.dart';
import 'package:audiflow/services/queue/default_queue_manager.dart';
import 'package:audiflow/services/queue/queue_manager.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/ui/app/navigation_helper.dart';
import 'package:audiflow/ui/app/seasoning_app.dart';
import 'package:audiflow/ui/color_schemes.g.dart';
import 'package:audiflow/ui/providers/podcast_refresher_provider.dart';
import 'package:audiflow/ui/widgets/error_notifier.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/messages_all.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

// ignore_for_file: avoid_print
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Logger.root.level = Level.FINE;

  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: - ${record.time}: ${record.loggerName}: '
      '${record.message}',
    );
  });

  NavigationHelper.setup();
  await SettingsService.setup();

  runApp(
    ProviderScope(
      overrides: [
        audioPlayerServiceProvider.overrideWith(MobileAudioPlayerService.new),
        queueManagerProvider.overrideWith(DefaultQueueManager.new),
      ],
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
        darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ja'),
        ],
        home: const Stack(
          children: [
            ErrorNotifier(),
            _GlobalProviders(),
            _ProvidersInitializer(
              child: SeasoningApp(
                key: Key('SeasoningApp'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// The Let's Encrypt certificate authority expired at the end of September
/// 2021.
/// Android devices running v7.1.1 or earlier will no longer trust their root
/// certificate which will cause issues when trying to fetch feeds and images
/// from sites secured with LE. This routine is called to add the new CA to the
/// trusted list at app start.
Future<List<int>> setupCertificateAuthority() async {
  var ca = <int>[];

  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final major = androidInfo.version.release.split('.');

    if ((int.tryParse(major[0]) ?? 100.0) < 8.0) {
      final data =
          await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
      ca = data.buffer.asUint8List();
      SecurityContext.defaultContext.setTrustedCertificatesBytes(ca);
    }
  }

  return ca;
}

class _GlobalProviders extends HookConsumerWidget {
  const _GlobalProviders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..watch(repositoryProvider)
      ..watch(settingsServiceProvider)
      ..watch(audioPlayerServiceProvider)
      ..watch(audioPlayerEventStreamProvider)
      ..watch(connectivityStateProvider)
      ..watch(audioQueueManagerProvider)
      ..watch(audioPositionSaverProvider)
      ..watch(podcastEventStreamProvider)
      ..watch(podcastRefresherProvider)
      ..watch(episodeEventStreamProvider)
      ..watch(downloadEventStreamProvider)
      ..watch(transcriptEventStreamProvider);

    return const SizedBox();
  }
}

class _ProvidersInitializer extends HookConsumerWidget {
  const _ProvidersInitializer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = useState(false);
    useEffect(
      () {
        if (initState.value) {
          return;
        }

        Future.wait([
          ref.read(downloadManagerProvider).ensureInitialized(),
          ref.read(queueManagerProvider.notifier).ensureInitialized(),
          ref.read(audioPlayerServiceProvider.notifier).ensureInitialized(),
          setupCertificateAuthority().then((ca) {
            ref.read(podcastApiProvider).addClientAuthorityBytes(ca);
          }),
        ]).then((_) {
          initState.value = true;
        });
        return;
      },
      [],
    );
    return initState.value ? child : const _Blank();
  }
}

class _Blank extends StatelessWidget {
  const _Blank();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor);
  }
}
