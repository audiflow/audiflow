import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/datasources/shared_preferences_datasource.dart';
import '../../../common/providers/platform_providers.dart';
import '../repositories/review_prompt_repository.dart';
import '../repositories/review_prompt_repository_impl.dart';
import '../services/review_prompt_trigger.dart';

part 'review_prompt_providers.g.dart';

@Riverpod(keepAlive: true)
ReviewPromptRepository reviewPromptRepository(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReviewPromptRepositoryImpl(SharedPreferencesDataSource(prefs));
}

@Riverpod(keepAlive: true)
ReviewPromptTrigger reviewPromptTrigger(Ref ref) {
  final repository = ref.watch(reviewPromptRepositoryProvider);
  final trigger = ReviewPromptTrigger(repository: repository);
  ref.onDispose(trigger.dispose);
  return trigger;
}

/// Subscribe to this from the presentation layer to know when to show
/// the review prompt. The gate widget checks foreground state before
/// actually displaying the dialog.
@Riverpod(keepAlive: true)
Stream<void> reviewPromptTriggerEvents(Ref ref) {
  return ref.watch(reviewPromptTriggerProvider).events;
}
