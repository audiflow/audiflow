import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../common/providers/logger_provider.dart';
import 'speech_recognition_repository.dart';

part 'speech_recognition_repository_impl.g.dart';

/// Provides a singleton [SpeechRecognitionRepository] instance.
@Riverpod(keepAlive: true)
SpeechRecognitionRepository speechRecognitionRepository(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('SpeechRecognition'));
  final repository = SpeechRecognitionRepositoryImpl(logger: logger);
  ref.onDispose(() => repository.dispose());
  return repository;
}

/// Implementation of [SpeechRecognitionRepository] using speech_to_text package.
class SpeechRecognitionRepositoryImpl implements SpeechRecognitionRepository {
  SpeechRecognitionRepositoryImpl({SpeechToText? speechToText, Logger? logger})
    : _speech = speechToText ?? SpeechToText(),
      _logger = logger;

  final SpeechToText _speech;
  final Logger? _logger;

  bool _isAvailable = false;
  SpeechErrorCallback? _errorCallback;

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isListening => _speech.isListening;

  String? _systemLocaleId;

  @override
  Future<bool> initialize() async {
    _logger?.i('Initializing speech recognition');

    try {
      _isAvailable = await _speech.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
      );

      if (_isAvailable) {
        // Get the system locale for speech recognition
        final systemLocale = await _speech.systemLocale();
        _systemLocaleId = systemLocale?.localeId;
        _logger?.i(
          'Speech recognition initialized successfully '
          '(locale: ${_systemLocaleId ?? "default"})',
        );
      } else {
        _logger?.w('Speech recognition not available on this device');
      }

      return _isAvailable;
    } catch (e) {
      _logger?.e('Failed to initialize speech recognition', error: e);
      _isAvailable = false;
      return false;
    }
  }

  @override
  Future<bool> startListening({
    required SpeechResultCallback onResult,
    SpeechStatusCallback? onStatus,
    SpeechErrorCallback? onError,
    String? localeId,
  }) async {
    if (!_isAvailable) {
      _logger?.w('Cannot start listening: speech recognition not available');
      return false;
    }

    if (_speech.isListening) {
      _logger?.d('Already listening, stopping first');
      await stopListening();
    }

    _errorCallback = onError;

    // Use provided locale, or fall back to system locale
    final effectiveLocaleId = localeId ?? _systemLocaleId;
    _logger?.i(
      'Starting speech recognition (locale: ${effectiveLocaleId ?? "default"})',
    );

    try {
      await _speech.listen(
        onResult: (result) {
          _logger?.d(
            'Speech result: "${result.recognizedWords}" '
            '(final: ${result.finalResult})',
          );
          onResult(result.recognizedWords, result.finalResult);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: effectiveLocaleId,
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          listenMode: ListenMode.confirmation,
        ),
      );

      return true;
    } catch (e) {
      _logger?.e('Failed to start listening', error: e);
      onError?.call('Failed to start listening: $e');
      return false;
    }
  }

  @override
  Future<void> stopListening() async {
    _logger?.i('Stopping speech recognition');
    await _speech.stop();
    _errorCallback = null;
  }

  @override
  Future<void> cancelListening() async {
    _logger?.i('Cancelling speech recognition');
    await _speech.cancel();
    _errorCallback = null;
  }

  @override
  void dispose() {
    _logger?.d('Disposing speech recognition repository');
    _speech.cancel();
    _errorCallback = null;
  }

  void _handleError(SpeechRecognitionError error) {
    _logger?.e('Speech recognition error: ${error.errorMsg}');
    _errorCallback?.call(error.errorMsg);
  }

  void _handleStatus(String status) {
    _logger?.d('Speech recognition status: $status');
  }
}
