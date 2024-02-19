// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/services/audio/mobile_audio_player_service.dart';
import 'package:seasoning/services/settings/settings_service.dart';
import 'package:seasoning/ui/app/seasoning_app.dart';

// ignore_for_file: avoid_print
void main() async {
  var certificateAuthorityBytes = <int>[];
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  Logger.root.level = Level.FINE;

  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: - ${record.time}: ${record.loggerName}: '
      '${record.message}',
    );
  });

  certificateAuthorityBytes = await setupCertificateAuthority();

  NavigationHelper.setup();
  await SettingsService.setup();

  runApp(
    const ProviderScope(
      child: _GlobalProviders(
        child: SeasoningApp(
            // certificateAuthorityBytes: certificateAuthorityBytes,
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

class _GlobalProviders extends ConsumerWidget {
  const _GlobalProviders({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.read(mobileAudioPlayerServiceProvider.notifier).setup();
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        return const SizedBox();
      },
    );
  }
}
