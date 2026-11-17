import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

/// Tells the user, once, that launch restored the data the OS carried over
/// from their previous device (`RestoreDetector`).
///
/// Sits in `MaterialApp.builder`, below the app's [ScaffoldMessenger], so
/// the snackbar waits for the first screen's scaffold and outlives route
/// changes. Launch raises the notice before the first frame, so it is read
/// once after that frame rather than listened to.
class ContinuityRestoreNoticeBanner extends ConsumerStatefulWidget {
  const ContinuityRestoreNoticeBanner({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ContinuityRestoreNoticeBanner> createState() =>
      _ContinuityRestoreNoticeBannerState();
}

class _ContinuityRestoreNoticeBannerState
    extends ConsumerState<ContinuityRestoreNoticeBanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIfDue());
  }

  void _showIfDue() {
    if (!mounted) return;
    if (!ref.read(continuityRestoreNoticeProvider).consume()) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).continuityRestoreNotice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
