package com.audiflow.ai

import org.json.JSONArray
import org.json.JSONObject

/**
 * Resolves voice transcriptions into settings changes using keyword matching
 * against a JSON settings schema.
 *
 * This mirrors the iOS SettingsIntentHandler logic.
 */
class SettingsIntentResolver {

    fun resolve(transcription: String, schemaJson: String): Map<String, Any?> {
        val schema = try {
            JSONObject(schemaJson)
        } catch (e: Exception) {
            return mapOf("action" to "not_found", "confidence" to 0.0)
        }

        val settings = schema.optJSONArray("settings")
            ?: return mapOf("action" to "not_found", "confidence" to 0.0)

        val text = transcription.lowercase()

        data class Match(val setting: JSONObject, val length: Int)

        val matches = mutableListOf<Match>()

        for (i in 0 until settings.length()) {
            val setting = settings.getJSONObject(i)
            val synonyms = setting.optJSONArray("synonyms") ?: continue
            var best = 0
            for (j in 0 until synonyms.length()) {
                val synonym = synonyms.getString(j).lowercase()
                if (text.contains(synonym) && best < synonym.length) {
                    best = synonym.length
                }
            }
            if (0 < best) matches.add(Match(setting, best))
        }

        if (matches.isEmpty()) return mapOf("action" to "not_found", "confidence" to 0.0)

        matches.sortByDescending { it.length }

        // Disambiguation: return ambiguous when top two matches tie
        if (1 < matches.size && matches[0].length == matches[1].length) {
            val candidates = matches.take(3).map { m ->
                mapOf(
                    "key" to m.setting.optString("key", ""),
                    "value" to m.setting.optString("currentValue", ""),
                    "confidence" to 0.6
                )
            }
            return mapOf("action" to "ambiguous", "candidates" to candidates, "confidence" to 0.6)
        }

        val best = matches[0].setting
        val key = best.optString("key", "")
        val constraints = best.optJSONObject("constraints")
        val constraintType = constraints?.optString("type", "") ?: ""

        // Enum detection
        if (constraintType == "options") {
            val values = constraints?.optJSONArray("values")
            if (values != null) {
                val target = detectOptionValue(text, values)
                if (target != null) {
                    return mapOf("action" to "absolute", "key" to key, "value" to target, "confidence" to 0.9)
                }
            }
        }

        // Boolean detection
        if (constraintType == "boolean") {
            val boolVal = detectBoolean(text)
            if (boolVal != null) {
                return mapOf("action" to "absolute", "key" to key, "value" to boolVal, "confidence" to 0.9)
            }
        }

        // Numeric / direction detection for range constraints
        if (constraintType == "range") {
            val numVal = detectNumeric(text, constraints)
            if (numVal != null) {
                return mapOf("action" to "absolute", "key" to key, "value" to numVal, "confidence" to 0.9)
            }
            val dir = detectDirection(text)
            if (dir != null) {
                val mag = detectMagnitude(text)
                return mapOf(
                    "action" to "relative",
                    "key" to key,
                    "direction" to dir,
                    "magnitude" to mag,
                    "confidence" to 0.85
                )
            }
        }

        return mapOf("action" to "not_found", "confidence" to 0.3)
    }

    // Maps canonical option values to their recognized aliases
    private val optionAliases = mapOf(
        "dark" to listOf("ダーク", "dark", "暗い", "暗く"),
        "light" to listOf("ライト", "light", "明るい", "明るく"),
        "system" to listOf("システム", "system", "自動", "auto"),
        "newestFirst" to listOf("新しい順", "newest", "新着順"),
        "oldestFirst" to listOf("古い順", "oldest"),
        "en" to listOf("英語", "english"),
        "ja" to listOf("日本語", "japanese"),
    )

    private fun detectOptionValue(text: String, options: JSONArray): String? {
        for (i in 0 until options.length()) {
            val option = options.getString(i)
            if (text.contains(option.lowercase())) return option
            optionAliases[option]?.forEach { alias ->
                if (text.contains(alias.lowercase())) return option
            }
        }
        return null
    }

    private fun detectBoolean(text: String): String? {
        val on = listOf("オン", "on", "有効", "使う", "つけ", "enable")
        val off = listOf("オフ", "off", "無効", "やめ", "消", "disable")
        on.forEach { if (text.contains(it.lowercase())) return "true" }
        off.forEach { if (text.contains(it.lowercase())) return "false" }
        return null
    }

    private fun detectNumeric(text: String, constraints: JSONObject?): String? {
        val match = Regex("(\\d+\\.?\\d*)").find(text) ?: return null
        val value = match.groupValues[1].toDoubleOrNull() ?: return null
        val min = constraints?.optDouble("min", 0.0) ?: 0.0
        val max = constraints?.optDouble("max", 100.0) ?: 100.0
        val clamped = value.coerceIn(min, max)
        return clamped.toString()
    }

    private fun detectDirection(text: String): String? {
        val inc = listOf("大きく", "上げ", "速く", "早く", "増や", "高く", "increase", "up", "faster", "higher", "bigger", "more")
        val dec = listOf("小さく", "下げ", "遅く", "減ら", "低く", "decrease", "down", "slower", "lower", "smaller", "less")
        inc.forEach { if (text.contains(it)) return "increase" }
        dec.forEach { if (text.contains(it)) return "decrease" }
        return null
    }

    private fun detectMagnitude(text: String): String {
        val large = listOf("かなり", "すごく", "めっちゃ", "大幅", "a lot", "much")
        val small = listOf("少し", "ちょっと", "やや", "a bit", "slightly")
        large.forEach { if (text.contains(it)) return "large" }
        small.forEach { if (text.contains(it)) return "small" }
        return "small"
    }
}
