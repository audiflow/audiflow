// ignore_for_file: type=lint

import 'package:intl/intl.dart' as intl;

import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get locale => 'ja';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'キャンセル';

  @override
  String get goBack => '戻る';

  @override
  String get continues => '続行';

  @override
  String get showMore => 'もっと見る';

  @override
  String get showLess => 'たたむ';

  @override
  String get clearSearchButton => 'クリア';

  @override
  String get subscriptions => 'フォロー中';

  @override
  String get popularPodcasts => '人気ポッドキャスト';

  @override
  String get recentlyPlayed => '再生履歴';

  @override
  String get latestEpisodes => '最新エピソード';

  @override
  String get home => 'ホーム';

  @override
  String get chart => 'チャート';

  @override
  String get search => '検索';

  @override
  String get library => 'Library';

  @override
  String get queue => '連続再生キュー';

  @override
  String get nullSeason => 'その他';

  @override
  String get clear => 'クリア';

  @override
  String get episode => 'エピソード';

  @override
  String get episodes => 'エピソード';

  @override
  String get season => 'シーズン';

  @override
  String get seasons => 'シーズン';

  @override
  String get settings => 'Settings';

  @override
  String get wifi => 'Wi-Fi';

  @override
  String get mobileData => 'モバイル回線';

  @override
  String nEpisodes(int count) {
    return '$countエピソード';
  }

  @override
  String get sec => '秒';

  @override
  String get min => '分';

  @override
  String get hour => '時間';

  @override
  String nDaysAgo(int count) {
    return '$count日前';
  }

  @override
  String nHoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String nMinutesAgo(int count) {
    return '$count分前';
  }

  @override
  String nSecondsAgo(int count) {
    return '$count秒前';
  }

  @override
  String get justNow => 'たった今';

  @override
  String get episodeFilterMode => '表示するエピソード';

  @override
  String get episodeFilterModeAll => 'すべてのエピソード';

  @override
  String get episodeFilterModePlayed => '再生済み';

  @override
  String get episodeFilterModeUnplayed => '未再生';

  @override
  String get episodeFilterModeDownloaded => 'ダウンロード済み';

  @override
  String get seasonFilterMode => 'Filter Seasons';

  @override
  String get seasonFilterModeAll => 'All seasons';

  @override
  String get seasonFilterModeUnplayed => '未再生あり';

  @override
  String get viewSortOldestToNewest => '古い順に並び替え';

  @override
  String get jumpToLastEpisode => '最後に聴いたエピソードへ';

  @override
  String get resume => '再開';

  @override
  String get play => '再生';

  @override
  String get pause => '一時停止';

  @override
  String get playFromStart => '最初から再生';

  @override
  String get playLatest => '最新のエピソードを再生';

  @override
  String get playAgain => '再生';

  @override
  String get tooltipPlay => 'エピソードを再生';

  @override
  String get tooltipPause => 'エピソード再生を一時停止';

  @override
  String get primaryQueue => '再生キュー（手動）';

  @override
  String get adhocQueue => '再生キュー（自動）';

  @override
  String get settingsOnDemandDownloadOnPlayback => '再生時の音源取得';

  @override
  String get settingsOnDemandDownloadOnPlaybackDescription => '事前ダウンロードがない場合、再生開始時に音源を取得します';

  @override
  String get settingsManualDownload => '手動ダウンロード';

  @override
  String get settingsManualDownloadDescription => 'エピソードを手動でダウンロードするとき';

  @override
  String get settingsAutoDownload => '自動ダウンロード';

  @override
  String get settingsAutoDownloadDescription => '様々な場面で自動的にダウンロードすることで、待ち時間や煩わしさを軽減します';

  @override
  String get settingsAutoDownloadEnabled => '有効';

  @override
  String get settingsAutoDownloadRecent => '直近公開エピソード取得件数';

  @override
  String get settingsAutoDownloadSubject => '';

  @override
  String get settingsAutoDownloadQueuedEpisodes => 'キューに手動で追加したエピソード';

  @override
  String get settingsAutoDownloadIncludesAdhoc => 'キューに自動追加されたエピソードも対象';

  @override
  String get settingsAutoDelete => '自動削除';

  @override
  String get settingsAutoDeleteDescription => '再生後にエピソードを自動で削除';

  @override
  String get settingsAutoDeleteAfter => '再生後';

  @override
  String get settingsAutoDeleteAfterDescription => '再生後にエピソードを自動で削除';

  @override
  String get settingsAutoDeleteAfterNever => 'しない';

  @override
  String get settingsAutoDeleteAfter1day => '1日';

  @override
  String get settingsAutoDeleteAfter3days => '3日';

  @override
  String get settingsAutoDeleteAfter7days => '7日';

  @override
  String get settingsAutoDeleteAfter14days => '14日';

  @override
  String get settingsAutoDeleteAfter30days => '30日';

  @override
  String get settingsWarnMobileData => 'モバイル回線接続時は警告を表示';

  @override
  String get settingsWarnMobileDataDescription => '従量課金制など通信量が気になる方に';

  @override
  String get settingsWarnWifi => 'Wi-Fi未接続時に警告を表示';

  @override
  String get settingsWifiOnly => 'Wi-Fi接続時のみ';

  @override
  String get settingsOpml => 'OPML Import/Export';

  @override
  String get settingsOpmlDescription => 'OPMLファイルを使ってポッドキャストをインポート/エクスポート';

  @override
  String get settingsOpmlImport => 'Import Podcasts via OPML File';

  @override
  String get settingsOpmlExport => 'Export Podcasts to OPML File';

  @override
  String get titleNoFiFi => 'Wi-Fi未接続';

  @override
  String get titleCellularConnection => 'モバイル回線接続中';

  @override
  String get captionStreamingNoWifi => 'WiFiが接続されていないため、モバイル回線で音声データを取得します。';

  @override
  String get captionDownloadNoWifi => '\'WiFiが接続されていないため、モバイル回線でエピソードをダウンロードします。\'';

  @override
  String get captionWarnSettingNavigation => 'この警告表示有無は設定で変更できます';

  @override
  String get proceedPlaying => '再生する';

  @override
  String get proceedDownload => '続行';

  @override
  String get downloadAllEpisodes => 'すべてのエピソードをダウンロード';

  @override
  String get downloadUnplayedEpisodes => '未再生のエピソードをダウンロード';

  @override
  String get semantics_podcast_details_header => 'ポッドキャスト詳細';

  @override
  String get search_for_podcasts_hint => 'ポッドキャストを検索…';

  @override
  String get semantic_announce_searching => '検索しています…';

  @override
  String get no_search_results_message => '該当するポッドキャストが見つかりませんでした';

  @override
  String get podcast_funding_dialog_header => 'ポッドキャストへのサポート';

  @override
  String get podcast_funding_consent_message => 'このポッドキャストをサポートするために、以下のリンクからサポートを行うことができます。';
}
