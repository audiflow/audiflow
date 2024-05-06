import 'package:audiflow/ui/app/router/router.dart';
import 'package:flutter/material.dart';

final class SearchNavigator {
  const SearchNavigator();

  void goLicensePage(BuildContext context) {
    const LicensePageRoute().go(context);
  }
}
