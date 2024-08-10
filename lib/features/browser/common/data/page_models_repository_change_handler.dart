import 'package:audiflow/features/browser/common/data/page_models_event.dart';
import 'package:audiflow/features/browser/common/data/page_models_repository.dart';
import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageModelsRepositoryChangeHandler implements PageModelsRepository {
  PageModelsRepositoryChangeHandler(this._ref, this._inner);

  final Ref _ref;
  final PageModelsRepository _inner;

  @override
  Future<PodcastDetailsPageModel?> findPodcastDetailsPageModel(int pid) =>
      _inner.findPodcastDetailsPageModel(pid);

  @override
  Future<PodcastDetailsPageModel> updatePodcastDetailsPageModel(
    PodcastDetailsPageModelUpdateParam param,
  ) async {
    final model = await _inner.updatePodcastDetailsPageModel(param);
    _ref
        .read(pageModelsEventStreamProvider.notifier)
        .add(PodcastDetailsPageModelUpdatedEvent(model));
    return model;
  }
}
