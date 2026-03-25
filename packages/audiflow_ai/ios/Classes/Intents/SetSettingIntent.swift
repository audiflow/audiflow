import AppIntents

@available(iOS 26.0, *)
struct SetSettingIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Setting"
    static var description = IntentDescription("Change an Audiflow setting to a specific value")

    @Parameter(title: "Setting Name")
    var settingName: SettingNameAppEnum

    @Parameter(title: "Value")
    var value: String

    func perform() async throws -> some IntentResult {
        guard let resolvedKey = SettingsKeyMapping.resolve(settingName.rawValue) else {
            throw SettingsIntentError.unknownSetting(settingName.rawValue)
        }
        // For out-of-app Siri invocation, apply directly via UserDefaults.
        // Flutter SharedPreferences uses UserDefaults on iOS. We must store
        // the correct native type so getDouble/getInt/getBool return non-null.
        let defaults = UserDefaults.standard
        let valueType = SettingsKeyMapping.valueType(for: resolvedKey)

        // "system" sentinel means "remove the key so Flutter reads its default"
        if value.lowercased() == "system", valueType == .string {
            defaults.removeObject(forKey: resolvedKey)
            return .result()
        }

        switch valueType {
        case .double:
            guard let parsed = Double(value) else {
                throw SettingsIntentError.invalidValue(value, expectedType: "number")
            }
            defaults.set(parsed, forKey: resolvedKey)
        case .int:
            // Accept "30.0" style strings from speech recognition
            guard let parsed = Double(value) else {
                throw SettingsIntentError.invalidValue(value, expectedType: "integer")
            }
            defaults.set(Int(parsed), forKey: resolvedKey)
        case .bool:
            guard let parsed = Self.parseBool(value) else {
                throw SettingsIntentError.invalidValue(value, expectedType: "true/false")
            }
            defaults.set(parsed, forKey: resolvedKey)
        case .string:
            defaults.set(value, forKey: resolvedKey)
        }

        return .result()
    }

    /// Parses a boolean from speech-friendly variants.
    private static func parseBool(_ value: String) -> Bool? {
        switch value.lowercased() {
        case "true", "yes", "on", "1": true
        case "false", "no", "off", "0": false
        default: nil
        }
    }
}

@available(iOS 26.0, *)
enum SettingsIntentError: Swift.Error, CustomLocalizedStringResourceConvertible {
    case unknownSetting(String)
    case adjustNotSupported
    case invalidValue(String, expectedType: String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .unknownSetting(let name):
            "Unknown setting: \(name)"
        case .adjustNotSupported:
            "Relative adjustments are only available in-app"
        case .invalidValue(let value, let expectedType):
            "Cannot interpret \"\(value)\" as \(expectedType)"
        }
    }
}

/// Native type that a setting key expects in UserDefaults.
enum SettingsValueType {
    case string
    case double
    case int
    case bool
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

    /// Maps internal key names to their expected native type in UserDefaults.
    /// Must stay aligned with `SettingsDefaults` in audiflow_core.
    private static let typeMapping: [String: SettingsValueType] = [
        // Strings / nullable strings
        "settings_theme_mode": .string,
        "settings_locale": .string,
        "settings_auto_play_order": .string,
        "settings_search_country": .string,
        // Doubles
        "settings_text_scale": .double,
        "settings_playback_speed": .double,
        "settings_auto_complete_threshold": .double,
        // Integers
        "settings_skip_forward_seconds": .int,
        "settings_skip_backward_seconds": .int,
        "settings_max_concurrent_downloads": .int,
        "settings_sync_interval_minutes": .int,
        // Booleans
        "settings_continuous_playback": .bool,
        "settings_wifi_only_download": .bool,
        "settings_auto_delete_played": .bool,
        "settings_auto_sync": .bool,
        "settings_wifi_only_sync": .bool,
        "settings_notify_new_episodes": .bool,
    ]

    static func resolve(_ name: String) -> String? {
        // Try exact match on the internal key first, then fall back to label lookup.
        if mapping.values.contains(name) {
            return name
        }
        return mapping[name.lowercased()]
    }

    /// Returns the expected native type for a resolved key.
    /// Defaults to `.string` for unknown keys.
    static func valueType(for key: String) -> SettingsValueType {
        typeMapping[key] ?? .string
    }
}
