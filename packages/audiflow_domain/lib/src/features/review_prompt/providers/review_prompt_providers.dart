import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../repositories/review_prompt_repository.dart';
import '../repositories/review_prompt_repository_impl.dart';
import '../services/review_prompt_trigger.dart';

part 'review_prompt_providers.g.dart';

@Riverpod(keepAlive: true)
ReviewPromptRepository reviewPromptRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final logger = ref.watch(appLoggerProvider);
  return ReviewPromptRepositoryImpl(
    SharedPreferencesDataSource(prefs),
    logger: logger,
  );
}

@Riverpod(keepAlive: true)
ReviewPromptTrigger reviewPromptTrigger(Ref ref) {
  final repository = ref.watch(reviewPromptRepositoryProvider);
  final logger = ref.watch(appLoggerProvider);
  final trigger = ReviewPromptTrigger(repository: repository, logger: logger);
  ref.onDispose(trigger.dispose);
  return trigger;
}

/// Stream of "prompt-ready" events. Consumers are responsible for
/// foreground gating; this stream fires regardless of app state.
@Riverpod(keepAlive: true)
Stream<void> reviewPromptTriggerEvents(Ref ref) {
  return ref.watch(reviewPromptTriggerProvider).events;
}
