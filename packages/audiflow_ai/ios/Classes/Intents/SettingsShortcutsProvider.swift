import AppIntents

@available(iOS 26.0, *)
struct SettingsShortcutsProvider: AppShortcutsProvider {
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
}
