// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

package com.audiflow.ai

import com.google.mlkit.genai.prompt.FeatureStatus
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.DisplayName
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test

/**
 * Unit tests for AudiflowAiPlugin.
 *
 * These tests verify the capability detection, initialization, and text generation
 * logic without requiring a device. Integration tests with ML Kit should run
 * on an Android device or emulator.
 */
class AudiflowAiPluginTest {

    @Nested
    @DisplayName("Task 4.1: Capability Detection - FeatureStatus Mapping")
    inner class CapabilityDetectionTests {

        @Test
        @DisplayName("mapFeatureStatusToCapability returns 'full' for AVAILABLE")
        fun testAvailableStatusMapsFull() {
            val result = AudiflowAiPlugin.mapFeatureStatusToCapability(FeatureStatus.AVAILABLE)
            assertEquals("full", result)
        }

        @Test
        @DisplayName("mapFeatureStatusToCapability returns 'needsSetup' for DOWNLOADABLE")
        fun testDownloadableStatusMapsNeedsSetup() {
            val result = AudiflowAiPlugin.mapFeatureStatusToCapability(FeatureStatus.DOWNLOADABLE)
            assertEquals("needsSetup", result)
        }

        @Test
        @DisplayName("mapFeatureStatusToCapability returns 'needsSetup' for DOWNLOADING")
        fun testDownloadingStatusMapsNeedsSetup() {
            val result = AudiflowAiPlugin.mapFeatureStatusToCapability(FeatureStatus.DOWNLOADING)
            assertEquals("needsSetup", result)
        }

        @Test
        @DisplayName("mapFeatureStatusToCapability returns 'unavailable' for UNAVAILABLE")
        fun testUnavailableStatusMapsUnavailable() {
            val result = AudiflowAiPlugin.mapFeatureStatusToCapability(FeatureStatus.UNAVAILABLE)
            assertEquals("unavailable", result)
        }

        @Test
        @DisplayName("mapFeatureStatusToCapability returns 'unavailable' for unknown status")
        fun testUnknownStatusMapsUnavailable() {
            // Test with an arbitrary unknown status value
            val result = AudiflowAiPlugin.mapFeatureStatusToCapability(999)
            assertEquals("unavailable", result)
        }
    }

    @Nested
    @DisplayName("Task 4.1: Capability Detection - Error Code Detection")
    inner class ErrorCodeTests {

        @Test
        @DisplayName("isAiCoreNotInstalledError returns true for code -101")
        fun testAiCoreNotInstalledErrorCode() {
            assertTrue(AudiflowAiPlugin.isAiCoreNotInstalledError(-101))
        }

        @Test
        @DisplayName("isAiCoreNotInstalledError returns false for code 0")
        fun testZeroErrorCode() {
            assertFalse(AudiflowAiPlugin.isAiCoreNotInstalledError(0))
        }

        @Test
        @DisplayName("isAiCoreNotInstalledError returns false for code -100")
        fun testNegative100ErrorCode() {
            assertFalse(AudiflowAiPlugin.isAiCoreNotInstalledError(-100))
        }

        @Test
        @DisplayName("isAiCoreNotInstalledError returns false for code 601 (CONNECTION_ERROR)")
        fun testConnectionErrorCode() {
            assertFalse(AudiflowAiPlugin.isAiCoreNotInstalledError(601))
        }

        @Test
        @DisplayName("isAiCoreNotInstalledError returns false for code 606 (FEATURE_NOT_FOUND)")
        fun testFeatureNotFoundErrorCode() {
            assertFalse(AudiflowAiPlugin.isAiCoreNotInstalledError(606))
        }
    }

    @Nested
    @DisplayName("Task 4.2: Initialization - System Instructions Validation")
    inner class InitializationStateTests {

        @Test
        @DisplayName("isValidSystemInstructions returns true for non-empty string")
        fun testValidSystemInstructions() {
            assertTrue(AudiflowAiPlugin.isValidSystemInstructions("You are a helpful assistant"))
        }

        @Test
        @DisplayName("isValidSystemInstructions returns true for null (uses default)")
        fun testNullSystemInstructionsIsValid() {
            assertTrue(AudiflowAiPlugin.isValidSystemInstructions(null))
        }

        @Test
        @DisplayName("isValidSystemInstructions returns false for empty string")
        fun testEmptySystemInstructionsIsInvalid() {
            assertFalse(AudiflowAiPlugin.isValidSystemInstructions(""))
        }

        @Test
        @DisplayName("isValidSystemInstructions returns false for blank string (spaces)")
        fun testBlankSystemInstructionsIsInvalid() {
            assertFalse(AudiflowAiPlugin.isValidSystemInstructions("   "))
        }

        @Test
        @DisplayName("isValidSystemInstructions returns false for blank string (tabs)")
        fun testTabsOnlySystemInstructionsIsInvalid() {
            assertFalse(AudiflowAiPlugin.isValidSystemInstructions("\t\t"))
        }

        @Test
        @DisplayName("isValidSystemInstructions returns true for string with leading/trailing spaces")
        fun testStringWithWhitespaceIsValid() {
            assertTrue(AudiflowAiPlugin.isValidSystemInstructions("  Valid instructions  "))
        }
    }

    @Nested
    @DisplayName("Task 4.3: Text Generation - Config Parsing")
    inner class GenerationConfigTests {

        private val plugin = AudiflowAiPlugin()

        @Test
        @DisplayName("parseGenerationConfig extracts temperature correctly as Double")
        fun testParseTemperatureDouble() {
            val config = mapOf("temperature" to 0.8)
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(0.8f, parsed.temperature, 0.001f)
        }

        @Test
        @DisplayName("parseGenerationConfig extracts temperature correctly as Float")
        fun testParseTemperatureFloat() {
            val config = mapOf("temperature" to 0.5f)
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(0.5f, parsed.temperature, 0.001f)
        }

        @Test
        @DisplayName("parseGenerationConfig uses default temperature 0.7 when missing")
        fun testDefaultTemperature() {
            val config = emptyMap<String, Any>()
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(0.7f, parsed.temperature, 0.001f)
        }

        @Test
        @DisplayName("parseGenerationConfig uses default temperature for null config")
        fun testNullConfig() {
            val parsed = plugin.parseGenerationConfig(null)
            assertEquals(0.7f, parsed.temperature, 0.001f)
            assertNull(parsed.maxOutputTokens)
        }

        @Test
        @DisplayName("parseGenerationConfig extracts maxOutputTokens correctly as Int")
        fun testParseMaxOutputTokensInt() {
            val config = mapOf("maxOutputTokens" to 256)
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(256, parsed.maxOutputTokens)
        }

        @Test
        @DisplayName("parseGenerationConfig extracts maxOutputTokens correctly as Long")
        fun testParseMaxOutputTokensLong() {
            val config = mapOf("maxOutputTokens" to 512L)
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(512, parsed.maxOutputTokens)
        }

        @Test
        @DisplayName("parseGenerationConfig uses null maxOutputTokens when missing")
        fun testDefaultMaxOutputTokens() {
            val config = emptyMap<String, Any>()
            val parsed = plugin.parseGenerationConfig(config)
            assertNull(parsed.maxOutputTokens)
        }

        @Test
        @DisplayName("parseGenerationConfig handles combined temperature and maxOutputTokens")
        fun testCombinedConfig() {
            val config = mapOf(
                "temperature" to 0.9,
                "maxOutputTokens" to 1024
            )
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(0.9f, parsed.temperature, 0.001f)
            assertEquals(1024, parsed.maxOutputTokens)
        }

        @Test
        @DisplayName("parseGenerationConfig handles invalid temperature type")
        fun testInvalidTemperatureType() {
            val config = mapOf("temperature" to "invalid")
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(0.7f, parsed.temperature, 0.001f) // Falls back to default
        }

        @Test
        @DisplayName("parseGenerationConfig handles invalid maxOutputTokens type")
        fun testInvalidMaxOutputTokensType() {
            val config = mapOf("maxOutputTokens" to "invalid")
            val parsed = plugin.parseGenerationConfig(config)
            assertNull(parsed.maxOutputTokens) // Falls back to null
        }

        @Test
        @DisplayName("parseGenerationConfig handles edge case temperature 0.0")
        fun testZeroTemperature() {
            val config = mapOf("temperature" to 0.0)
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(0.0f, parsed.temperature, 0.001f)
        }

        @Test
        @DisplayName("parseGenerationConfig handles edge case temperature 1.0")
        fun testMaxTemperature() {
            val config = mapOf("temperature" to 1.0)
            val parsed = plugin.parseGenerationConfig(config)
            assertEquals(1.0f, parsed.temperature, 0.001f)
        }
    }

    @Nested
    @DisplayName("Task 4.3: Text Generation - Response Structure")
    inner class ParsedGenerationConfigTests {

        @Test
        @DisplayName("ParsedGenerationConfig data class equality works correctly")
        fun testDataClassEquality() {
            val config1 = AudiflowAiPlugin.ParsedGenerationConfig(0.7f, 256)
            val config2 = AudiflowAiPlugin.ParsedGenerationConfig(0.7f, 256)
            assertEquals(config1, config2)
        }

        @Test
        @DisplayName("ParsedGenerationConfig data class inequality for different temperature")
        fun testDataClassInequalityTemperature() {
            val config1 = AudiflowAiPlugin.ParsedGenerationConfig(0.7f, 256)
            val config2 = AudiflowAiPlugin.ParsedGenerationConfig(0.8f, 256)
            assertNotEquals(config1, config2)
        }

        @Test
        @DisplayName("ParsedGenerationConfig data class inequality for different maxOutputTokens")
        fun testDataClassInequalityMaxTokens() {
            val config1 = AudiflowAiPlugin.ParsedGenerationConfig(0.7f, 256)
            val config2 = AudiflowAiPlugin.ParsedGenerationConfig(0.7f, 512)
            assertNotEquals(config1, config2)
        }

        @Test
        @DisplayName("ParsedGenerationConfig handles null maxOutputTokens")
        fun testNullMaxOutputTokens() {
            val config = AudiflowAiPlugin.ParsedGenerationConfig(0.7f, null)
            assertNull(config.maxOutputTokens)
        }
    }
}
