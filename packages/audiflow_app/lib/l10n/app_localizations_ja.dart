// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonClear => 'クリア';

  @override
  String get commonOk => 'OK';

  @override
  String get commonDelete => '削除';

  @override
  String get commonLoading => '読み込み中...';

  @override
  String get commonComingSoon => '近日公開';

  @override
  String get commonDone => '完了';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearanceTitle => '外観';

  @override
  String get settingsAppearanceSubtitle => 'テーマ、言語、文字サイズ';

  @override
  String get settingsPlaybackTitle => '再生';

  @override
  String get settingsPlaybackSubtitle => '速度、スキップ、自動完了';

  @override
  String get settingsDownloadsTitle => 'ダウンロード';

  @override
  String get settingsDownloadsSubtitle => 'WiFi、自動削除、同時ダウンロード数';

  @override
  String get settingsFeedSyncTitle => 'フィード同期';

  @override
  String get settingsFeedSyncSubtitle => '更新間隔、バックグラウンド同期';

  @override
  String get settingsStorageTitle => 'ストレージとデータ';

  @override
  String get settingsStorageSubtitle => 'キャッシュ、OPML、データ管理';

  @override
  String get settingsAboutTitle => 'アプリについて';

  @override
  String get settingsAboutSubtitle => 'バージョン、ライセンス、サポート';

  @override
  String get appearanceThemeMode => 'テーマモード';

  @override
  String get appearanceThemeLight => 'ライト';

  @override
  String get appearanceThemeDark => 'ダーク';

  @override
  String get appearanceThemeSystem => 'システム';

  @override
  String get appearanceLanguage => '言語';

  @override
  String get appearanceLanguageEnglish => 'English';

  @override
  String get appearanceLanguageJapanese => '日本語';

  @override
  String get appearanceTextSize => '文字サイズ';

  @override
  String get appearanceTextSmall => '小';

  @override
  String get appearanceTextMedium => '中';

  @override
  String get appearanceTextLarge => '大';

  @override
  String get appearancePreviewText => '現在のサイズでのプレビュー';

  @override
  String get playbackDefaultSpeed => 'デフォルト再生速度';

  @override
  String get playbackSkipForward => 'スキップ（秒）';

  @override
  String get playbackSkipBackward => '巻き戻し（秒）';

  @override
  String get playbackAutoCompleteThreshold => '自動完了しきい値';

  @override
  String get playbackContinuousTitle => '連続再生';

  @override
  String get playbackContinuousSubtitle => 'キュー内の次のエピソードを自動再生';

  @override
  String get playbackAutoPlayOrderTitle => '自動再生の順序';

  @override
  String get playbackAutoPlayOrderSubtitle => 'エピソードリストからの自動キュー追加時の順序';

  @override
  String get playbackAutoPlayOrderOldestFirst => '配信順';

  @override
  String get playbackAutoPlayOrderAsDisplayed => '表示順';

  @override
  String get downloadsWifiOnlyTitle => 'WiFiのみダウンロード';

  @override
  String get downloadsWifiOnlySubtitle => 'WiFi接続時のみダウンロード';

  @override
  String get downloadsAutoDeleteTitle => '再生後に自動削除';

  @override
  String get downloadsAutoDeleteSubtitle => '再生済みエピソードのダウンロードを削除';

  @override
  String get downloadsMaxConcurrent => '最大同時ダウンロード数';

  @override
  String get feedSyncAutoSyncTitle => '自動同期';

  @override
  String get feedSyncAutoSyncSubtitle => 'ポッドキャストフィードを自動更新';

  @override
  String get feedSyncInterval => '同期間隔';

  @override
  String get feedSyncInterval30min => '30分';

  @override
  String get feedSyncInterval1hour => '1時間';

  @override
  String get feedSyncInterval2hours => '2時間';

  @override
  String get feedSyncInterval4hours => '4時間';

  @override
  String get feedSyncWifiOnlyTitle => 'WiFiのみ同期';

  @override
  String get feedSyncWifiOnlySubtitle => 'WiFi接続時のみフィードを同期';

  @override
  String get feedSyncNotifyNewEpisodesTitle => '新しいエピソードの通知';

  @override
  String get feedSyncNotifyNewEpisodesSubtitle =>
      'バックグラウンド更新で新しいエピソードが見つかったときに通知を表示';

  @override
  String get feedSyncInterval15min => '15分ごと';

  @override
  String get feedSyncInterval3hours => '3時間ごと';

  @override
  String get feedSyncInterval6hours => '6時間ごと';

  @override
  String get feedSyncInterval12hours => '12時間ごと';

  @override
  String get notificationPermissionRequiredTitle => '権限が必要です';

  @override
  String get notificationPermissionRequiredMessage =>
      '通知の権限が拒否されました。システム設定から有効にしてください。';

  @override
  String get notificationPermissionOpenSettings => '設定を開く';

  @override
  String get storageImageCache => '画像キャッシュ';

  @override
  String get storageImageCacheSubtitle => '一時ファイルとキャッシュ画像を削除';

  @override
  String get storageClearCache => 'キャッシュをクリア';

  @override
  String get storageClearCacheTitle => 'キャッシュをクリアしますか？';

  @override
  String get storageClearCacheContent =>
      'すべての一時ファイルとキャッシュ画像が削除されます。必要に応じて再ダウンロードされます。';

  @override
  String get storageCacheCleared => 'キャッシュをクリアしました';

  @override
  String get storageSearchHistory => '検索履歴';

  @override
  String get storageSearchHistorySubtitle => '検索候補をクリア';

  @override
  String get storageClearSearchHistoryTitle => '検索履歴をクリアしますか？';

  @override
  String get storageClearSearchHistoryContent => '保存された検索候補がすべて削除されます。';

  @override
  String get storageSearchHistoryCleared => '検索履歴をクリアしました';

  @override
  String get storageExportTitle => '購読をエクスポート';

  @override
  String get storageExportSubtitle => 'OPMLファイルとして保存';

  @override
  String get storageExport => 'エクスポート';

  @override
  String get storageExportEmpty => 'エクスポートする購読がありません';

  @override
  String get storageExportSuccess => '購読をエクスポートしました';

  @override
  String storageExportError(String message) {
    return 'エクスポート失敗: $message';
  }

  @override
  String get storageImportTitle => '購読をインポート';

  @override
  String get storageImportSubtitle => 'OPMLファイルからインポート';

  @override
  String get storageImport => 'インポート';

  @override
  String get storageDangerZone => '危険ゾーン';

  @override
  String get storageResetTitle => 'すべてのデータをリセット';

  @override
  String get storageResetSubtitle => 'すべてのデータを削除して初期状態に戻す';

  @override
  String get storageResetDialogTitle => 'すべてのデータをリセットしますか？';

  @override
  String get storageResetDialogContent =>
      '購読、ダウンロード、再生履歴、設定を含むすべてのデータが完全に削除されます。';

  @override
  String get storageResetTypeConfirm => '確認のため RESET と入力:';

  @override
  String get storageResetButton => 'リセット';

  @override
  String get storageResetComplete => 'データのリセットが完了しました';

  @override
  String storageResetFailed(String error) {
    return 'リセット失敗: $error';
  }

  @override
  String get storageImportComplete => 'インポート完了';

  @override
  String storageImportedCount(int count) {
    return '$count件のポッドキャストをインポートしました';
  }

  @override
  String storageAlreadySubscribedCount(int count) {
    return '$count件は購読済み';
  }

  @override
  String storageFailedCount(int count) {
    return '$count件が失敗';
  }

  @override
  String get aboutTagline => 'あなたのポッドキャストパートナー';

  @override
  String get aboutVersion => 'バージョン';

  @override
  String get aboutLicenses => 'オープンソースライセンス';

  @override
  String get aboutSendFeedback => 'フィードバックを送る';

  @override
  String get aboutRateApp => 'アプリを評価';

  @override
  String get libraryTitle => 'ライブラリ';

  @override
  String librarySyncResult(int successCount, int errorCount) {
    return '$successCount件のフィードを同期、$errorCount件が失敗';
  }

  @override
  String librarySyncSuccess(int count) {
    return '$count件のフィードを同期しました';
  }

  @override
  String get libraryYourPodcasts => 'あなたのポッドキャスト';

  @override
  String get libraryEmpty => '購読がありません';

  @override
  String get libraryEmptySubtitle => 'ポッドキャストを検索して購読しましょう';

  @override
  String get libraryLoadError => '購読の読み込みに失敗しました';

  @override
  String get librarySortByLatestEpisode => '最新エピソード順';

  @override
  String get librarySortBySubscribedAt => '登録日順';

  @override
  String get librarySortByAlphabetical => '名前順';

  @override
  String get searchTitle => 'ポッドキャストを検索';

  @override
  String get searchHint => 'ポッドキャストを検索...';

  @override
  String get searchInitialTitle => 'ポッドキャストを検索';

  @override
  String get searchInitialSubtitle => 'キーワードを入力してポッドキャストを探す';

  @override
  String get searchEmpty => 'ポッドキャストが見つかりません';

  @override
  String get searchEmptySubtitle => '別の検索ワードをお試しください';

  @override
  String get searchErrorUnavailable => '接続できません。インターネット接続を確認してください。';

  @override
  String get searchErrorTimeout => '検索がタイムアウトしました。もう一度お試しください。';

  @override
  String get searchErrorRateLimit => 'リクエストが多すぎます。しばらくお待ちください。';

  @override
  String get searchErrorInvalid => '有効な検索ワードを入力してください。';

  @override
  String get searchErrorGeneric => 'エラーが発生しました。もう一度お試しください。';

  @override
  String get searchErrorBanner => '検索に失敗しました。以前の結果を表示しています。';

  @override
  String get searchRefreshingLabel => '新しい結果を読み込み中';

  @override
  String get searchRegionLabel => '検索リージョン';

  @override
  String searchRegionCurrent(String country) {
    return '$countryで検索中';
  }

  @override
  String get searchRegionPickerTitle => 'リージョンを選択';

  @override
  String get searchRegionPickerSubtitle => 'ポッドキャストを検索するiTunesストア';

  @override
  String get queueTitle => 'キュー';

  @override
  String get queueUpNext => '次に再生';

  @override
  String get queueEmpty => 'キューは空です';

  @override
  String get queueEmptySubtitle => 'ライブラリやポッドキャストページからエピソードを追加';

  @override
  String get queueLoadError => 'キューの読み込みに失敗しました';

  @override
  String get queueClearTooltip => 'キューをクリア';

  @override
  String get queueClearConfirm => '確認？';

  @override
  String get queueAddedToQueue => 'キューに追加しました';

  @override
  String get queuePlayingNext => '次に再生します';

  @override
  String get queueAddToQueueTooltip => 'キューに追加（長押しで次に再生）';

  @override
  String get playerCloseLabel => 'プレーヤーを閉じる';

  @override
  String get playerNowPlaying => '再生中';

  @override
  String get playerNoAudio => '再生中の音声はありません';

  @override
  String get playerArtworkLabel => 'エピソードのアートワーク';

  @override
  String playerRewindLabel(int seconds) {
    return '$seconds秒巻き戻し';
  }

  @override
  String playerForwardLabel(int seconds) {
    return '$seconds秒早送り';
  }

  @override
  String get playerLoadingLabel => '読み込み中';

  @override
  String get playerPauseLabel => '一時停止';

  @override
  String get playerPlayLabel => '再生';

  @override
  String playerSpeedLabel(String speed) {
    return '再生速度 $speed倍';
  }

  @override
  String playerNowPlayingLabel(String title, String podcast) {
    return '再生中: $title - $podcast';
  }

  @override
  String get podcastDetailFeedUrlMissing => 'フィードURLがありません';

  @override
  String get podcastDetailFeedUrlMissingSubtitle => 'このポッドキャストにはフィードURLがありません';

  @override
  String get podcastDetailLoadError => 'エピソードの読み込みに失敗しました';

  @override
  String get podcastDetailUngrouped => '未分類';

  @override
  String get podcastDetailSubscribed => '購読中';

  @override
  String get podcastDetailSubscribe => '購読する';

  @override
  String get podcastDetailNoResults => '結果が見つかりません';

  @override
  String get podcastDetailNoMatchingEpisodes => '一致するエピソードがありません';

  @override
  String get podcastDetailTryDifferentFilter => '別のフィルターをお試しください';

  @override
  String get podcastDetailNoEpisodes => 'エピソードが見つかりません';

  @override
  String get podcastDetailPlaylistEmpty => 'このプレイリストにはエピソードがありません';

  @override
  String podcastDetailEpisodeLoadError(String error) {
    return 'エピソード読み込みエラー: $error';
  }

  @override
  String podcastDetailEpisodeCount(int count) {
    return '$countエピソード';
  }

  @override
  String podcastDetailGroupCount(int count) {
    return '$countグループ';
  }

  @override
  String get podcastDetailOldestFirst => '古い順';

  @override
  String get podcastDetailNewestFirst => '新しい順';

  @override
  String podcastDetailFailedToLoad(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get episodeReplaceQueueTitle => 'キューを置き換えますか？';

  @override
  String get episodeReplaceQueueContent =>
      '再生を開始すると、現在のキューがこのリストのエピソードに置き換わります。';

  @override
  String get episodeReplace => '置き換え';

  @override
  String get downloadCancelled => 'ダウンロードをキャンセルしました';

  @override
  String get downloadRetrying => 'ダウンロードを再試行中';

  @override
  String get downloadStarted => 'ダウンロードを開始しました';

  @override
  String get downloadDeleteTitle => 'ダウンロードを削除しますか？';

  @override
  String get downloadDeleteContent => 'ダウンロードしたファイルが削除されます。';

  @override
  String get downloadDeleted => 'ダウンロードを削除しました';

  @override
  String get downloadManageTitle => 'ダウンロード管理';

  @override
  String get downloadScreenTitle => 'ダウンロード';

  @override
  String get downloadLoadError => 'ダウンロードの読み込みに失敗しました';

  @override
  String get downloadDeleteAllCompleted => '完了済みをすべて削除';

  @override
  String get downloadCompletedDeleted => '完了済みのダウンロードを削除しました';

  @override
  String get downloadStatusDownloading => 'ダウンロード中';

  @override
  String get downloadStatusPending => '待機中';

  @override
  String get downloadStatusPaused => '一時停止';

  @override
  String get downloadStatusCompleted => '完了';

  @override
  String get downloadStatusFailed => '失敗';

  @override
  String get downloadStatusCancelled => 'キャンセル';

  @override
  String get downloadEmptyTitle => 'ダウンロードはありません';

  @override
  String downloadSectionCount(String status, int count) {
    return '$status（$count）';
  }

  @override
  String get downloadAllEpisodes => '全エピソードをダウンロード';

  @override
  String get downloadAllConfirmTitle => 'エピソードをダウンロードしますか？';

  @override
  String downloadAllConfirmContent(int count) {
    return '$count件のエピソードをダウンロードします。';
  }

  @override
  String downloadAllLimitNote(int limit) {
    return '最初の$limit件に制限されます。';
  }

  @override
  String downloadAllQueued(int count) {
    return '$count件のダウンロードをキューに追加';
  }

  @override
  String get downloadCancelAll => 'ダウンロードをキャンセル';

  @override
  String downloadCancelAllDone(int count) {
    return '$count件のダウンロードをキャンセルしました';
  }

  @override
  String get downloadResumeAll => 'ダウンロードを再開';

  @override
  String downloadResumeAllDone(int count) {
    return '$count件のダウンロードを再開しました';
  }

  @override
  String get downloadsBatchLimitTitle => '一括ダウンロード上限';

  @override
  String get downloadsBatchLimitSubtitle => '一度にダウンロードするエピソードの最大数';

  @override
  String get opmlImportTitle => 'ポッドキャストをインポート';

  @override
  String get opmlAlreadySubscribed => '購読済み';

  @override
  String opmlImportSelected(int count) {
    return '選択をインポート ($count)';
  }

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
  String get episodeMoreActions => 'その他のアクション';

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

  @override
  String get playerTabNowPlaying => '再生中';

  @override
  String get playerTabTranscript => '書き起こし';

  @override
  String get playerTranscriptLoading => '書き起こしを読み込み中...';

  @override
  String get playerTranscriptEmpty => '書き起こしがありません';

  @override
  String get playerTranscriptJumpToCurrent => '現在位置へ';

  @override
  String get episodeTranscriptAvailable => '書き起こしあり';

  @override
  String get podcastAutoDownloadTitle => '新しいエピソードを自動ダウンロード';

  @override
  String get podcastAutoDownloadSubtitle => 'バックグラウンド更新時に新しいエピソードを自動でダウンロード';

  @override
  String get stationSectionTitle => 'ステーション';

  @override
  String get stationNew => '新規ステーション';

  @override
  String get stationName => 'ステーション名';

  @override
  String get stationNameHint => '例: ニュース、テック、お笑い';

  @override
  String get stationPodcasts => 'ポッドキャスト';

  @override
  String get stationFilters => 'フィルタ';

  @override
  String get stationPlaybackOrder => '再生順';

  @override
  String get stationNewest => '新しい順';

  @override
  String get stationOldest => '古い順';

  @override
  String get stationFilterAll => '全エピソード';

  @override
  String get stationFilterUnplayed => '未再生';

  @override
  String get stationFilterInProgress => '再生中';

  @override
  String get stationFilterDownloaded => 'ダウンロード済みのみ';

  @override
  String get stationFilterFavorited => 'お気に入りのみ';

  @override
  String get stationFilterDuration => '再生時間';

  @override
  String stationFilterShorterThan(int minutes) {
    return '$minutes分未満';
  }

  @override
  String stationFilterLongerThan(int minutes) {
    return '$minutes分以上';
  }

  @override
  String stationFilterPublishedWithin(int days) {
    return '過去$days日以内';
  }

  @override
  String stationLimitReached(int max) {
    return 'ステーション上限に達しました($max)';
  }

  @override
  String get stationDeleteConfirm => 'このステーションを削除しますか？';

  @override
  String stationEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countエピソード',
      zero: 'エピソードなし',
    );
    return '$_temp0';
  }

  @override
  String stationPodcastCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countポッドキャスト',
    );
    return '$_temp0';
  }

  @override
  String get stationEmpty => 'すべて聴き終わりました!';

  @override
  String get stationPlayAll => 'すべて再生';

  @override
  String get stationNoStationsYet => 'ステーションがありません。+ をタップして作成してください。';

  @override
  String get stationNoSubscriptionsYet => 'まだ購読がありません。';

  @override
  String get stationEmptySubtitle => '新しいエピソードが自動的に表示されます。';

  @override
  String get stationEditTitle => 'ステーションを編集';

  @override
  String get stationSave => '保存';

  @override
  String get stationDelete => 'ステーションを削除';

  @override
  String get stationDeleteTitle => 'ステーションを削除';

  @override
  String get stationDeleteBody => 'このステーションを削除しますか？この操作は元に戻せません。';

  @override
  String get stationFilterHideCompletedLabel => '再生済みを非表示';

  @override
  String get stationFilterDownloadedLabel => 'ダウンロード済みのみ';

  @override
  String get stationFilterFavoritedLabel => 'お気に入りのみ';

  @override
  String get stationDurationFilter => '再生時間フィルタ';

  @override
  String get stationShorterThan => 'より短い';

  @override
  String get stationLongerThan => 'より長い';

  @override
  String get stationDurationMinutesSuffix => '分';

  @override
  String get stationEpisodeOrder => 'エピソードの順序';

  @override
  String get stationNewestFirst => '新しい順';

  @override
  String get stationOldestFirst => '古い順';

  @override
  String get stationEditTooltip => 'ステーションを編集';

  @override
  String get stationNotFoundTitle => 'ステーションが見つかりません';

  @override
  String get stationNotFoundMessage => 'ステーションのデータが利用できません';

  @override
  String get stationNameRequired => 'ステーション名を入力してください';

  @override
  String get stationPodcastRequired => 'ポッドキャストを1つ以上選択してください';

  @override
  String get stationEpisodes => 'エピソード';

  @override
  String get stationLatestOnly => '最新のみ';

  @override
  String stationLatestN(int count) {
    return '最新$count話';
  }

  @override
  String get stationAllEpisodes => 'すべて';

  @override
  String get stationGroupByPodcast => '番組ごとにまとめる';

  @override
  String get stationPodcastOrder => '番組の並び順';

  @override
  String get stationPodcastSortSubscribeOld => '購読順（古い順）';

  @override
  String get stationPodcastSortSubscribeNew => '購読順（新しい順）';

  @override
  String get stationPodcastSortNameAz => '名前順（A-Z）';

  @override
  String get stationPodcastSortNameZa => '名前順（Z-A）';

  @override
  String get stationPodcastSortManual => '手動';

  @override
  String get stationReorder => '並べ替え';

  @override
  String get stationReorderDone => '完了';

  @override
  String get stationSelectPodcasts => 'ポッドキャストを選択...';

  @override
  String stationSelectPodcastsCount(int selected, int total) {
    return '$selected / $total';
  }

  @override
  String get stationPickerTitle => 'ポッドキャストを選択';

  @override
  String get stationPickerSearch => 'ポッドキャストを検索...';

  @override
  String stationPickerSubscribed(int count) {
    return '$count件購読中';
  }

  @override
  String stationPickerResults(int count) {
    return '$count件の結果';
  }

  @override
  String get stationPickerSortNameAz => '名前順（A-Z）';

  @override
  String get stationPickerSortNameZa => '名前順（Z-A）';

  @override
  String get stationPickerSortRecentlySubscribed => '最近購読した順';

  @override
  String get stationPickerSortRecentlyUpdated => '最近更新された順';

  @override
  String stationDefault(String label) {
    return 'デフォルト（$label）';
  }

  @override
  String get stationDefaultAll => 'デフォルト（すべて）';

  @override
  String get commonGoBack => '戻る';

  @override
  String get deepLinkPodcastNotFound => 'ポッドキャストが見つかりません';

  @override
  String get deepLinkEpisodeNotFound => 'エピソードが見つかりません';

  @override
  String get deepLinkNetworkError => '読み込めませんでした。接続を確認してください';

  @override
  String get deepLinkLoading => 'リンクを開いています...';

  @override
  String get sharePodcast => 'ポッドキャストを共有';

  @override
  String get voiceCommandButton => '音声コマンド';

  @override
  String get voiceListening => '聞いています...';

  @override
  String get voiceProcessing => '処理中...';

  @override
  String voiceExecuting(String intent) {
    return '実行中: $intent';
  }

  @override
  String voiceCouldNotUnderstand(String transcription) {
    return '認識できませんでした: 「$transcription」';
  }

  @override
  String get voiceSettingsWhichSetting => 'どの設定を変更しますか？';

  @override
  String get voiceSettingsChanged => '設定を変更しました';

  @override
  String get undo => '元に戻す';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get voiceTapMicToRetry => 'マイクをタップしてやり直す';

  @override
  String get navSearch => '検索';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navQueue => 'キュー';

  @override
  String get navSettings => '設定';

  @override
  String get settingsVoiceTitle => '音声';

  @override
  String get settingsVoiceSubtitle => '音声コマンドと認識';

  @override
  String get voiceExperimentalLabel => '試験的機能';

  @override
  String get voiceExperimentalDescription =>
      '音声コマンドは試験的な機能であり、ほとんどのデバイスでは正常に動作しない可能性があります。デバイスのオンデバイスAI性能の向上に伴い、精度や対応状況も改善されていく見込みです。';

  @override
  String get voiceEnabledTitle => '音声コマンド';

  @override
  String get voiceEnabledSubtitle => 'アプリの音声操作を有効にする';

  @override
  String get voiceAvailableCommands => '利用可能なコマンド';

  @override
  String get voiceCommandPlay => '再生 / 再生を再開';

  @override
  String get voiceCommandPause => '一時停止';

  @override
  String get voiceCommandStop => '停止';

  @override
  String get voiceCommandSkipForward => '早送り';

  @override
  String get voiceCommandSkipBackward => '巻き戻し';

  @override
  String get voiceCommandSearch => 'ポッドキャストを検索';

  @override
  String get voiceCommandGoToLibrary => 'ライブラリに移動';

  @override
  String get voiceCommandGoToQueue => 'キューに移動';

  @override
  String get voiceCommandOpenSettings => '設定を開く';

  @override
  String get voiceCommandChangeSettings => '設定を変更';

  @override
  String get voiceIntentPlay => '再生';

  @override
  String get voiceIntentPause => '一時停止';

  @override
  String get voiceIntentStop => '停止';

  @override
  String get voiceIntentSkipForward => '早送り';

  @override
  String get voiceIntentSkipBackward => '巻き戻し';

  @override
  String get voiceIntentSeek => 'シーク';

  @override
  String get voiceIntentSearch => '検索';

  @override
  String get voiceIntentGoToLibrary => 'ライブラリ';

  @override
  String get voiceIntentGoToQueue => 'キュー';

  @override
  String get voiceIntentOpenSettings => '設定';

  @override
  String get voiceIntentAddToQueue => 'キューに追加';

  @override
  String get voiceIntentRemoveFromQueue => 'キューから削除';

  @override
  String get voiceIntentClearQueue => 'キューをクリア';

  @override
  String get voiceIntentChangeSettings => '設定を変更';

  @override
  String get voiceIntentUnknown => '不明';

  @override
  String get playNext => '次に再生';

  @override
  String get downloadEpisode => 'エピソードをダウンロード';

  @override
  String get goToEpisode => 'エピソードへ移動';

  @override
  String get removeDownload => 'ダウンロードを削除';

  @override
  String get statsTitle => 'タイトル';

  @override
  String get statsPodcast => 'ポッドキャスト';

  @override
  String get statsDuration => '再生時間';

  @override
  String get statsPublished => '公開日';

  @override
  String get statsTimesCompleted => '完了回数';

  @override
  String get statsTimesStarted => '再生回数';

  @override
  String get statsTotalListened => '総再生時間';

  @override
  String get statsRealtime => '実時間';

  @override
  String get statsFirstPlayed => '初回再生';

  @override
  String get statsLastPlayed => '最終再生';

  @override
  String get statsNever => '未再生';

  @override
  String get statsSection => '統計';

  @override
  String get commonCopiedToClipboard => 'クリップボードにコピーしました';
}
