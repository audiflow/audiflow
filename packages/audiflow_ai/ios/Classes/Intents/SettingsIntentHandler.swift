import Foundation

@available(iOS 26.0, *)
class SettingsIntentHandler {

    func resolve(transcription: String, schemaJson: String) -> [String: Any] {
        guard let data = schemaJson.data(using: .utf8),
              let schema = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let settings = schema["settings"] as? [[String: Any]] else {
            return ["action": "not_found", "confidence": 0.0]
        }

        let text = transcription.lowercased()

        var matches: [(setting: [String: Any], length: Int)] = []
        for setting in settings {
            guard let synonyms = setting["synonyms"] as? [String] else { continue }
            var best = 0
            for synonym in synonyms {
                let lower = synonym.lowercased()
                if text.contains(lower) && best < lower.count {
                    best = lower.count
                }
            }
            if 0 < best {
                matches.append((setting, best))
            }
        }

        guard !matches.isEmpty else {
            return ["action": "not_found", "confidence": 0.0]
        }

        // Sort by match length descending (longest synonym match wins)
        matches.sort { $1.length < $0.length }

        // Check for disambiguation (multiple equally-good matches)
        if 1 < matches.count && matches[0].length == matches[1].length {
            let candidates: [[String: Any]] = matches.prefix(3).map {
                [
                    "key": $0.setting["key"] as? String ?? "",
                    "value": $0.setting["currentValue"] as? String ?? "",
                    "confidence": 0.6,
                ]
            }
            return ["action": "ambiguous", "candidates": candidates, "confidence": 0.6]
        }

        let best = matches[0].setting
        let key = best["key"] as? String ?? ""
        let constraints = best["constraints"] as? [String: Any] ?? [:]
        let constraintType = constraints["type"] as? String ?? ""

        // Try enum value detection
        if constraintType == "options",
           let values = constraints["values"] as? [String],
           let target = detectOptionValue(text: text, options: values) {
            return ["action": "absolute", "key": key, "value": target, "confidence": 0.9]
        }

        // Try boolean detection
        if constraintType == "boolean",
           let boolVal = detectBoolean(text: text) {
            return ["action": "absolute", "key": key, "value": boolVal, "confidence": 0.9]
        }

        // Try numeric or relative direction detection
        if constraintType == "range" {
            if let numVal = detectNumeric(text: text, constraints: constraints) {
                return ["action": "absolute", "key": key, "value": numVal, "confidence": 0.9]
            }
            if let dir = detectDirection(text: text) {
                let mag = detectMagnitude(text: text)
                return ["action": "relative", "key": key, "direction": dir,
                        "magnitude": mag, "confidence": 0.85]
            }
        }

        return ["action": "not_found", "confidence": 0.3]
    }

    // MARK: - Detection helpers

    // Maps canonical option values to their recognized aliases (including locale variants)
    private let optionAliases: [String: [String]] = [
        "dark": ["ダーク", "dark", "暗い", "暗く"],
        "light": ["ライト", "light", "明るい", "明るく"],
        "system": ["システム", "system", "自動", "auto"],
        "newestFirst": ["新しい順", "newest", "新着順"],
        "oldestFirst": ["古い順", "oldest"],
        "en": ["英語", "english"],
        "ja": ["日本語", "japanese"],
    ]

    private func detectOptionValue(text: String, options: [String]) -> String? {
        for option in options {
            if text.contains(option.lowercased()) { return option }
            if let aliases = optionAliases[option] {
                for alias in aliases where text.contains(alias.lowercased()) {
                    return option
                }
            }
        }
        return nil
    }

    private func detectBoolean(text: String) -> String? {
        let on = ["オン", "on", "有効", "使う", "つけ", "enable"]
        let off = ["オフ", "off", "無効", "やめ", "消", "disable"]
        for kw in on where text.contains(kw.lowercased()) { return "true" }
        for kw in off where text.contains(kw.lowercased()) { return "false" }
        return nil
    }

    private func detectNumeric(text: String, constraints: [String: Any]) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "(\\d+\\.?\\d*)"),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range(at: 1), in: text),
              let value = Double(text[range]) else { return nil }
        let min = constraints["min"] as? Double ?? 0
        let max = constraints["max"] as? Double ?? 100
        // Clamp value to [min, max] without using > or >=
        let clamped = Swift.min(max, Swift.max(min, value))
        return String(clamped)
    }

    private func detectDirection(text: String) -> String? {
        let inc = ["大きく", "上げ", "速く", "早く", "増や", "高く",
                   "increase", "up", "faster", "higher", "bigger", "more"]
        let dec = ["小さく", "下げ", "遅く", "減ら", "低く",
                   "decrease", "down", "slower", "lower", "smaller", "less"]
        for kw in inc where text.contains(kw) { return "increase" }
        for kw in dec where text.contains(kw) { return "decrease" }
        return nil
    }

    private func detectMagnitude(text: String) -> String {
        let large = ["かなり", "すごく", "めっちゃ", "大幅", "a lot", "much"]
        let small = ["少し", "ちょっと", "やや", "a bit", "slightly"]
        for kw in large where text.contains(kw) { return "large" }
        for kw in small where text.contains(kw) { return "small" }
        // Default to small magnitude when no modifier is detected
        return "small"
    }
}
