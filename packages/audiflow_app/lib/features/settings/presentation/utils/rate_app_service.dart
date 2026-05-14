import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rate_app_service.g.dart';

/// Service that opens the App Store / Play Store listing so the user can rate
/// the app.
///
/// Wrapped behind a provider so widget tests can substitute a recording fake
/// without touching the platform channel.
abstract class RateAppService {
  Future<void> openStoreListing();
}

/// App Store identifier for the iOS/macOS audiflow listing.
///
/// Sourced from the live App Store URL referenced by the force-update
/// fallback (`https://apps.apple.com/app/id6479216840`).
const _appStoreId = '6479216840';

class _InAppReviewRateAppService implements RateAppService {
  const _InAppReviewRateAppService();

  @override
  Future<void> openStoreListing() =>
      InAppReview.instance.openStoreListing(appStoreId: _appStoreId);
}

@Riverpod(keepAlive: true)
RateAppService rateAppService(Ref ref) => const _InAppReviewRateAppService();
