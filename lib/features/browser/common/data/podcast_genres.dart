import 'package:audiflow/constants/genres.dart';
import 'package:audiflow/features/preference/data/app_locale.dart';
import 'package:audiflow/features/preference/data/app_preference_repository.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_genres.freezed.dart';
part 'podcast_genres.g.dart';

@Riverpod(keepAlive: true)
class PodcastGenres extends _$PodcastGenres {
  @override
  PodcastGenresState build() {
    ref.listen(
        appPreferenceRepositoryProvider
            .select((settings) => settings.searchProvider), (_, __) {
      _refreshGenres();
    });

    return _refreshGenres();
  }

  PodcastGenresState _refreshGenres() {
    final locale = ref.read(appLocaleProvider);
    final searchProvider =
        ref.read(appPreferenceRepositoryProvider).searchProvider;
    var categoryList = '';
    var categories = <String>[];

    /// Fetch the correct categories for the current local and selected
    /// provider.
    if (searchProvider == 'itunes') {
      categories = itunesGenres;
      categoryList = Intl.message(
        'discovery_categories_itunes',
        locale: locale.languageCode,
      );
    } else {
      categories = podcastIndexGenres;
      categoryList = Intl.message(
        'discovery_categories_pindex',
        locale: locale.languageCode,
      );
    }

    return PodcastGenresState(
      categories: categories,
      intlCategories: categoryList.split(','),
      intlCategoriesSorted: categoryList
          .split(',')
          .sorted((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
    );
  }

  /// The service providers expect the genre to be passed in English.
  /// This function takes the selected genre and returns the English version.
  String decodeGenre(String? genre) {
    final index = state.intlCategories.indexOf(genre ?? '');
    return index < 0
        ? ''
        : state.categories[index] == '<All>'
            ? ''
            : state.categories[index];
  }
}

@freezed
class PodcastGenresState with _$PodcastGenresState {
  const factory PodcastGenresState({
    @Default([]) List<String> categories,
    @Default([]) List<String> intlCategories,
    @Default([]) List<String> intlCategoriesSorted,
  }) = _PodcastGenresState;
}
