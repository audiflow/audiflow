import 'package:audiflow/ui/app/router/router.dart';
import 'package:flutter/material.dart';

final class HomeNavigator {
  const HomeNavigator();

  void goDebugPage(BuildContext context) {
    const DebugPageRoute().go(context);
  }

  void pushSettingPage(BuildContext context) {
    const HomeSettingPageRoute().push<void>(context);
  }
}
