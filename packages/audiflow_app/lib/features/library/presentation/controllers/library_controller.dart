import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_controller.g.dart';

/// Provides a reactive stream of user's podcast subscriptions.
///
/// Updates automatically when subscriptions change in the database.
@riverpod
Stream<List<Subscription>> librarySubscriptions(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider).watchSubscriptions();
}
