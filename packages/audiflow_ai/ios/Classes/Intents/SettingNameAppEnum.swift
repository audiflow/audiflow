import AppIntents

/// Known settings exposed to Siri Shortcuts.
///
/// Each case maps to a key recognized by `SettingsKeyMapping.resolve(_:)`.
/// Display representations include localized synonyms so Siri can match
/// spoken variants ("playback speed", "speed", "再生速度", etc.).
@available(iOS 26.0, *)
enum SettingNameAppEnum: String, AppEnum {
    case theme
    case language
    case textSize = "text size"
    case playbackSpeed = "playback speed"
    case skipForward = "skip forward"
    case skipBackward = "skip backward"
    case continuousPlayback = "continuous playback"
    case autoPlayOrder = "auto play order"
    case wifiOnlyDownload = "wifi only download"
    case autoDeletePlayed = "auto delete played"
    case maxConcurrentDownloads = "max concurrent downloads"
    case autoSync = "auto sync"
    case syncInterval = "sync interval"
    case wifiOnlySync = "wifi only sync"
    case notifyNewEpisodes = "notify new episodes"
    case searchCountry = "search country"
    case autoCompleteThreshold = "auto complete threshold"

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Setting"
    }

    static var caseDisplayRepresentations: [SettingNameAppEnum: DisplayRepresentation] {
        [
            .theme: .init(title: "Theme", synonyms: ["Theme Mode", "テーマ"]),
            .language: .init(title: "Language", synonyms: ["Locale", "言語"]),
            .textSize: .init(title: "Text Size", synonyms: ["Font Size", "文字サイズ"]),
            .playbackSpeed: .init(title: "Playback Speed", synonyms: ["Speed", "再生速度"]),
            .skipForward: .init(title: "Skip Forward", synonyms: ["スキップ（進む）"]),
            .skipBackward: .init(title: "Skip Backward", synonyms: ["Skip Back", "スキップ（戻る）"]),
            .continuousPlayback: .init(title: "Continuous Playback", synonyms: ["連続再生"]),
            .autoPlayOrder: .init(title: "Auto Play Order", synonyms: ["再生順"]),
            .wifiOnlyDownload: .init(title: "Wi-Fi Only Download", synonyms: ["WiFiダウンロード"]),
            .autoDeletePlayed: .init(title: "Auto Delete Played", synonyms: ["再生済み自動削除"]),
            .maxConcurrentDownloads: .init(title: "Max Concurrent Downloads", synonyms: ["同時ダウンロード数"]),
            .autoSync: .init(title: "Auto Sync", synonyms: ["自動同期"]),
            .syncInterval: .init(title: "Sync Interval", synonyms: ["同期間隔"]),
            .wifiOnlySync: .init(title: "Wi-Fi Only Sync", synonyms: ["WiFi同期"]),
            .notifyNewEpisodes: .init(title: "Notify New Episodes", synonyms: ["新エピソード通知"]),
            .searchCountry: .init(title: "Search Country", synonyms: ["検索国"]),
            .autoCompleteThreshold: .init(title: "Auto Complete Threshold", synonyms: ["自動完了しきい値"]),
        ]
    }
}

/// Direction for relative setting adjustments.
@available(iOS 26.0, *)
enum AdjustDirectionAppEnum: String, AppEnum {
    case increase
    case decrease

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Direction"
    }

    static var caseDisplayRepresentations: [AdjustDirectionAppEnum: DisplayRepresentation] {
        [
            .increase: .init(title: "Increase", synonyms: ["Up", "Higher", "More", "上げる", "増やす"]),
            .decrease: .init(title: "Decrease", synonyms: ["Down", "Lower", "Less", "下げる", "減らす"]),
        ]
    }
}
