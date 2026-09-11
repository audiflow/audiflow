import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../consent/presentation/controllers/privacy_consent_controller.dart';
import '../../../onboarding/presentation/controllers/onboarding_completion_controller.dart';
import 'analytics_opt_in_controller.dart';
import 'last_tab_controller.dart';
import 'theme_controller.dart';

/// Drops the in-memory copies of preferences held by keep-alive controllers
/// and routes to the consent screen, so a completed data reset resumes the
/// fresh-install flow without a relaunch.
///
/// `DataResetService` clears the stores; this is the presentation-layer
/// half that makes the UI reflect it. Navigation is skipped when no router
/// is mounted (widget tests).
void applyRuntimeReset(BuildContext context, WidgetRef ref) {
  ref
    ..invalidate(themeModeControllerProvider)
    ..invalidate(textScaleControllerProvider)
    ..invalidate(analyticsOptInControllerProvider)
    ..invalidate(lastTabControllerProvider)
    ..invalidate(privacyConsentControllerProvider)
    ..invalidate(onboardingCompletionControllerProvider);
  GoRouter.maybeOf(context)?.go(AppRoutes.consent);
}
