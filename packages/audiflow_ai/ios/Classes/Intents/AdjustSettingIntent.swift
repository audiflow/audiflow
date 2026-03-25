import AppIntents

@available(iOS 26.0, *)
struct AdjustSettingIntent: AppIntent {
    static var title: LocalizedStringResource = "Adjust Setting"
    static var description = IntentDescription("Increase or decrease an Audiflow setting")

    @Parameter(title: "Setting Name")
    var settingName: SettingNameAppEnum

    @Parameter(title: "Direction")
    var direction: AdjustDirectionAppEnum

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Relative changes need current value + step info from the registry,
        // which is only available via the Flutter-side platform channel.
        // Return a friendly dialog instead of throwing so users understand
        // the limitation without seeing an error.
        .result(dialog: "Relative adjustments (increase/decrease) are only available inside the app. Please open Audiflow and use voice commands there.")
    }
}
