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
        // For out-of-app Siri invocation, apply directly via UserDefaults
        // (Flutter SharedPreferences uses UserDefaults on iOS)
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: settingName)
        return .result()
    }
}
