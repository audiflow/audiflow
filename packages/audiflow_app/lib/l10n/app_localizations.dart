import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// NewsConnect weekday episodes playlist name
  ///
  /// In en, this message translates to:
  /// **'Daily News'**
  String get smartPlaylistDailyNews;

  /// NewsConnect non-weekday episodes playlist name
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get smartPlaylistPrograms;

  /// COTEN Radio extras playlist name
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get smartPlaylistExtras;

  /// Catch-all playlist name for uncategorized episodes
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get smartPlaylistOthers;

  /// Section header for smart playlists in podcast detail
  ///
  /// In en, this message translates to:
  /// **'Smart Playlists'**
  String get smartPlaylistSectionTitle;

  /// Label for episodes view tab
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodesLabel;

  /// Label for smart playlists view tab
  ///
  /// In en, this message translates to:
  /// **'Smart Playlists'**
  String get smartPlaylistsLabel;

  /// Title for episode detail screen
  ///
  /// In en, this message translates to:
  /// **'Episode details'**
  String get episodeDetails;

  /// Tooltip for share episode button
  ///
  /// In en, this message translates to:
  /// **'Share episode'**
  String get shareEpisode;

  /// Action to mark episode as played
  ///
  /// In en, this message translates to:
  /// **'Mark as played'**
  String get markAsPlayed;

  /// Action to mark episode as unplayed
  ///
  /// In en, this message translates to:
  /// **'Mark as unplayed'**
  String get markAsUnplayed;

  /// Action to add episode to playback queue
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// Relative date label for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// Relative date label for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dateYesterday;

  /// Episode count for smart playlist group card
  ///
  /// In en, this message translates to:
  /// **'{count} episodes'**
  String groupEpisodeCount(int count);

  /// Duration with hours and minutes for group card
  ///
  /// In en, this message translates to:
  /// **'{hours}h{minutes}m'**
  String groupDurationHoursMinutes(int hours, int minutes);

  /// Duration in minutes for group card
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String groupDurationMinutes(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
