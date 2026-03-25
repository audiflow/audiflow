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
                ],
                shortTitle: "Change Setting",
                systemImageName: "gear"
            ),
            AppShortcut(
                intent: AdjustSettingIntent(),
                phrases: [
                    "\(.applicationName)の設定を調整",
                    "\(.applicationName) adjust setting",
                ],
                shortTitle: "Adjust Setting",
                systemImageName: "slider.horizontal.3"
            ),
        ]
    }
}
