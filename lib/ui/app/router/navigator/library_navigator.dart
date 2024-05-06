import 'package:audiflow/ui/app/router/router.dart';
import 'package:flutter/material.dart';

final class LibraryNavigator {
  const LibraryNavigator();

  void goLicensePage(BuildContext context) {
    const LicensePageRoute().go(context);
  }
}
