/// Callback for speech recognition results.
typedef SpeechResultCallback = void Function(String text, bool isFinal);

/// Callback for speech recognition status changes.
typedef SpeechStatusCallback = void Function(String status);

/// Callback for speech recognition errors.
typedef SpeechErrorCallback = void Function(String errorMessage);

/// Repository interface for speech-to-text functionality.
///
/// Abstracts the underlying speech recognition implementation, allowing
/// for easier testing and potential platform-specific implementations.
abstract class SpeechRecognitionRepository {
  /// Whether speech recognition is available on this device.
  bool get isAvailable;

  /// Whether currently listening for speech input.
  bool get isListening;

  /// Initialize the speech recognition service.
  ///
  /// Must be called before using other methods.
  /// Returns true if initialization was successful.
  Future<bool> initialize();

  /// Start listening for speech input.
  ///
  /// [onResult] is called with recognition results.
  /// [onStatus] is called when the listening status changes.
  /// [onError] is called if an error occurs.
  /// [localeId] optionally specifies the language (e.g., 'en_US').
  ///
  /// Returns true if listening started successfully.
  Future<bool> startListening({
    required SpeechResultCallback onResult,
    SpeechStatusCallback? onStatus,
    SpeechErrorCallback? onError,
    String? localeId,
  });

  /// Stop listening for speech input.
  Future<void> stopListening();

  /// Cancel listening without processing any results.
  Future<void> cancelListening();

  /// Dispose resources used by the speech recognition service.
  void dispose();
}
