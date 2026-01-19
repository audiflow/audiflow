/// iTunes podcast genres with their corresponding genre IDs.
///
/// This enum provides all 19 podcast genres supported by the iTunes Search API,
/// each with its unique genre ID as defined by Apple.
enum ItunesGenre {
  /// Arts genre (ID: 1301)
  arts(1301, 'Arts'),

  /// Business genre (ID: 1321)
  business(1321, 'Business'),

  /// Comedy genre (ID: 1303)
  comedy(1303, 'Comedy'),

  /// Education genre (ID: 1304)
  education(1304, 'Education'),

  /// Fiction genre (ID: 1483)
  fiction(1483, 'Fiction'),

  /// Government genre (ID: 1511)
  government(1511, 'Government'),

  /// Health & Fitness genre (ID: 1512)
  healthAndFitness(1512, 'Health & Fitness'),

  /// History genre (ID: 1487)
  history(1487, 'History'),

  /// Kids & Family genre (ID: 1305)
  kidsAndFamily(1305, 'Kids & Family'),

  /// Leisure genre (ID: 1502)
  leisure(1502, 'Leisure'),

  /// Music genre (ID: 1310)
  music(1310, 'Music'),

  /// News genre (ID: 1489)
  news(1489, 'News'),

  /// Religion & Spirituality genre (ID: 1314)
  religionAndSpirituality(1314, 'Religion & Spirituality'),

  /// Science genre (ID: 1533)
  science(1533, 'Science'),

  /// Society & Culture genre (ID: 1324)
  societyAndCulture(1324, 'Society & Culture'),

  /// Sports genre (ID: 1545)
  sports(1545, 'Sports'),

  /// TV & Film genre (ID: 1309)
  tvAndFilm(1309, 'TV & Film'),

  /// Technology genre (ID: 1318)
  technology(1318, 'Technology'),

  /// True Crime genre (ID: 1488)
  trueCrime(1488, 'True Crime')
  ;

  /// Creates an iTunes genre with the specified [genreId] and [genreName].
  const ItunesGenre(this.genreId, this.genreName);

  /// The unique iTunes genre ID.
  final int genreId;

  /// The human-readable genre name.
  final String genreName;

  /// Returns a translation key for this genre.
  ///
  /// The translation key follows the format: `itunes_genre_{enumName}`
  ///
  /// Example:
  /// ```dart
  /// print(ItunesGenre.comedy.translationKey); // itunes_genre_comedy
  /// print(ItunesGenre.healthAndFitness.translationKey); // itunes_genre_healthAndFitness
  /// ```
  String get translationKey => 'itunes_genre_$name';

  /// Returns a localized display name for this genre.
  ///
  /// If no [localize] function is provided, returns the English [genreName].
  /// Otherwise, calls the provided function with the [translationKey] and
  /// [genreName] as the default value.
  ///
  /// This allows consuming applications to provide their own localization
  /// without adding dependencies to this package.
  ///
  /// Example with intl package:
  /// ```dart
  /// String localizeGenre(String key, String defaultValue) {
  ///   return Intl.message(
  ///     defaultValue,
  ///     name: key,
  ///     desc: 'Genre name for iTunes podcast genre',
  ///   );
  /// }
  ///
  /// final displayName = ItunesGenre.comedy.getLocalizedName(localizeGenre);
  /// ```
  ///
  /// Example with custom map:
  /// ```dart
  /// final translations = {
  ///   'itunes_genre_comedy': 'コメディ',
  ///   'itunes_genre_music': '音楽',
  /// };
  ///
  /// String localizer(String key, String defaultValue) {
  ///   return translations[key] ?? defaultValue;
  /// }
  ///
  /// final name = ItunesGenre.comedy.getLocalizedName(localizer); // コメディ
  /// ```
  String getLocalizedName([
    String Function(String key, String defaultValue)? localize,
  ]) {
    if (localize == null) {
      return genreName;
    }
    return localize(translationKey, genreName);
  }

  /// Converts a genre name to its corresponding [ItunesGenre].
  ///
  /// Returns `null` if the name is null or doesn't match any genre.
  /// The comparison is case-sensitive.
  ///
  /// Example:
  /// ```dart
  /// final genre = ItunesGenre.fromName('Comedy');
  /// print(genre?.genreId); // 1303
  /// ```
  static ItunesGenre? fromName(String? name) {
    if (name == null) {
      return null;
    }

    try {
      return ItunesGenre.values.firstWhere(
        (genre) => genre.genreName == name,
      );
    } on StateError {
      return null;
    }
  }

  /// Converts a genre ID to its corresponding [ItunesGenre].
  ///
  /// Returns `null` if the ID is null or doesn't match any genre.
  ///
  /// Example:
  /// ```dart
  /// final genre = ItunesGenre.fromId(1303);
  /// print(genre?.genreName); // Comedy
  /// ```
  static ItunesGenre? fromId(int? id) {
    if (id == null) {
      return null;
    }

    try {
      return ItunesGenre.values.firstWhere(
        (genre) => genre.genreId == id,
      );
    } on StateError {
      return null;
    }
  }
}
