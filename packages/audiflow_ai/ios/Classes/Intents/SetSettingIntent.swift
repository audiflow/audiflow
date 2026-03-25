import AppIntents

@available(iOS 26.0, *)
struct SetSettingIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Setting"
    static var description = IntentDescription("Change an Audiflow setting to a specific value")

    @Parameter(title: "Setting Name")
    var settingName: String

    @Parameter(title: "Value")
    var value: String

    func perform() async throws -> some IntentResult {
        guard let resolvedKey = SettingsKeyMapping.resolve(settingName) else {
            throw SettingsIntentError.unknownSetting(settingName)
        }
        // For out-of-app Siri invocation, apply directly via UserDefaults
        // (Flutter SharedPreferences uses UserDefaults on iOS)
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: resolvedKey)
        return .result()
    }
}

@available(iOS 26.0, *)
enum SettingsIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case unknownSetting(String)
    case adjustNotSupported

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .unknownSetting(let name):
            "Unknown setting: \(name)"
        case .adjustNotSupported:
            "Relative adjustments are only available in-app"
        }
    }
}

/// Maps user-facing setting names to internal SharedPreferences keys.
///
/// Keys must match `SettingsKeys` constants in audiflow_core.
enum SettingsKeyMapping {
    private static let mapping: [String: String] = [
        "theme": "settings_theme_mode",
        "theme mode": "settings_theme_mode",
        "language": "settings_locale",
        "locale": "settings_locale",
        "text size": "settings_text_scale",
        "font size": "settings_text_scale",
        "playback speed": "settings_playback_speed",
        "speed": "settings_playback_speed",
        "skip forward": "settings_skip_forward_seconds",
        "skip backward": "settings_skip_backward_seconds",
        "skip back": "settings_skip_backward_seconds",
        "auto complete threshold": "settings_auto_complete_threshold",
        "continuous playback": "settings_continuous_playback",
        "auto play order": "settings_auto_play_order",
        "wifi only download": "settings_wifi_only_download",
        "auto delete played": "settings_auto_delete_played",
        "max concurrent downloads": "settings_max_concurrent_downloads",
        "auto sync": "settings_auto_sync",
        "sync interval": "settings_sync_interval_minutes",
        "wifi only sync": "settings_wifi_only_sync",
        "notify new episodes": "settings_notify_new_episodes",
        "search country": "settings_search_country",
    ]

    static func resolve(_ name: String) -> String? {
        // Try exact match on the internal key first, then fall back to label lookup.
        if mapping.values.contains(name) {
            return name
        }
        return mapping[name.lowercased()]
    }
}
