import 'dart:io';

import 'package:audiflow/constants/env.dart';
import 'package:package_info_plus/package_info_plus.dart';

String _userAgent = '';

String getUserAgent() => _userAgent;

Future<void> populateUserAgent() async {
  if (Env.userAgentAppString.isNotEmpty) {
    _userAgent = Env.userAgentAppString;
    return;
  }

  final platform =
      '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'.trim();

  final packageInfo = await PackageInfo.fromPlatform();
  final appName = packageInfo.appName;
  final version = packageInfo.version;
  final buildNumber = packageInfo.buildNumber;
  _userAgent = '$appName/$version $buildNumber (phone;$platform)';
}
