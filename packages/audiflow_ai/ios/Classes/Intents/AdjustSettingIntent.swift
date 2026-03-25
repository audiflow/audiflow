import AppIntents

@available(iOS 26.0, *)
struct AdjustSettingIntent: AppIntent {
    static var title: LocalizedStringResource = "Adjust Setting"
    static var description = IntentDescription("Increase or decrease an Audiflow setting")

    @Parameter(title: "Setting Name")
    var settingName: String

    @Parameter(title: "Direction")
    var direction: String

    func perform() async throws -> some IntentResult {
        // Relative changes need current value + step info from the registry,
        // which is only available via the Flutter-side platform channel.
        throw SettingsIntentError.adjustNotSupported
    }
}
