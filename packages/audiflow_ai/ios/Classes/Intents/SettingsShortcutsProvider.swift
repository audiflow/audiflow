import AppIntents

@available(iOS 26.0, *)
struct SettingsShortcutsProvider: AppShortcutsProvider {
    // Xcode 26 (Swift 6.2+) added @AppShortcutsBuilder result builder to the
    // protocol, so the body uses builder syntax (no array brackets / commas).
    #if compiler(>=6.2)
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SetSettingIntent(),
            phrases: [
                "\(.applicationName)の設定を変更",
                "\(.applicationName) change setting",
                "\(.applicationName)の\(\.$settingName)を変更",
                "\(.applicationName) change \(\.$settingName)",
            ],
            shortTitle: "Change Setting",
            systemImageName: "gear"
        )
        AppShortcut(
            intent: AdjustSettingIntent(),
            phrases: [
                "\(.applicationName)の設定を調整",
                "\(.applicationName) adjust setting",
                "\(.applicationName)の\(\.$settingName)を調整",
                "\(.applicationName) adjust \(\.$settingName)",
            ],
            shortTitle: "Adjust Setting",
            systemImageName: "slider.horizontal.3"
        )
    }
    #else
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: SetSettingIntent(),
                phrases: [
                    "\(.applicationName)の設定を変更",
                    "\(.applicationName) change setting",
                    "\(.applicationName)の\(\.$settingName)を\(\.$value)に設定",
                    "\(.applicationName) set \(\.$settingName) to \(\.$value)",
                ],
                shortTitle: "Change Setting",
                systemImageName: "gear"
            ),
            AppShortcut(
                intent: AdjustSettingIntent(),
                phrases: [
                    "\(.applicationName)の設定を調整",
                    "\(.applicationName) adjust setting",
                    "\(.applicationName)の\(\.$settingName)を\(\.$direction)",
                    "\(.applicationName) \(\.$direction) \(\.$settingName)",
                ],
                shortTitle: "Adjust Setting",
                systemImageName: "slider.horizontal.3"
            ),
        ]
    }
    #endif
}
