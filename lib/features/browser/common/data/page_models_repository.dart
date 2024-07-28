import 'package:audiflow/features/browser/podcast/model/podcast_details_page_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'page_models_repository.g.dart';

abstract class PageModelsRepository {
  // -- PodcastDetailsPageModel

  Future<PodcastDetailsPageModel?> findPodcastDetailsPageModel(int pid);

  Future<PodcastDetailsPageModel> updatePodcastDetailsPageModel(
    PodcastDetailsPageModelUpdateParam param,
  );
}

@Riverpod(keepAlive: true)
PageModelsRepository pageModelsRepository(PageModelsRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
