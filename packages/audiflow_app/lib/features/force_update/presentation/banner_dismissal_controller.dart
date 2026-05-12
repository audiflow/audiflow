import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'banner_dismissal_controller.g.dart';

/// Session-scoped flag indicating the user dismissed the soft-update banner.
///
/// Intentionally not persisted: the banner reappears on the next cold start
/// so we keep nudging without becoming intrusive within a single session.
@Riverpod(keepAlive: true)
class SoftUpdateBannerDismissed extends _$SoftUpdateBannerDismissed {
  @override
  bool build() => false;

  void dismiss() => state = true;
}
