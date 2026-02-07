// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get smartPlaylistDailyNews => '平日版';

  @override
  String get smartPlaylistPrograms => '特集';

  @override
  String get smartPlaylistExtras => '番外編';

  @override
  String get smartPlaylistOthers => 'その他';

  @override
  String get smartPlaylistSectionTitle => 'スマートプレイリスト';

  @override
  String get episodesLabel => 'エピソード';

  @override
  String get smartPlaylistsLabel => 'スマートプレイリスト';

  @override
  String get episodeDetails => 'エピソード詳細';

  @override
  String get shareEpisode => 'エピソードを共有';

  @override
  String get markAsPlayed => '再生済みにする';

  @override
  String get markAsUnplayed => '未再生にする';

  @override
  String get addToQueue => 'キューに追加';

  @override
  String get dateToday => '今日';

  @override
  String get dateYesterday => '昨日';

  @override
  String groupEpisodeCount(int count) {
    return '$countエピソード';
  }

  @override
  String groupDurationHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String groupDurationMinutes(int minutes) {
    return '$minutes分';
  }
}
