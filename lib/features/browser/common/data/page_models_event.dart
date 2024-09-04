import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_models_event.g.dart';

sealed class PageModelsEvent {}

class PodcastDetailsPageModelUpdatedEvent implements PageModelsEvent {
  const PodcastDetailsPageModelUpdatedEvent(this.model);

  final PodcastDetailsPageModel model;
}

@Riverpod(keepAlive: true)
class PageModelsEventStream extends _$PageModelsEventStream {
  @override
  Stream<PageModelsEvent> build() async* {}

  void add(PageModelsEvent event) {
    state = AsyncData(event);
  }
}
