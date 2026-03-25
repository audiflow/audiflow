// Portions of this code are derived from flutter_local_ai
// (https://github.com/kekko7072/flutter_local_ai)
// Copyright (c) 2025 kekko7072
// Licensed under the MIT License

import 'package:flutter/services.dart';

/// Platform channel constants for AudiflowAi.
class AudiflowAiChannel {
  AudiflowAiChannel._();

  /// The method channel name.
  static const String name = 'com.audiflow/ai';

  /// Method names.
  static const String checkCapability = 'checkCapability';
  static const String initialize = 'initialize';
  static const String generateText = 'generateText';
  static const String dispose = 'dispose';
  static const String promptAiCoreInstall = 'promptAiCoreInstall';
  static const String resolveSettingsIntent = 'resolveSettingsIntent';

  /// Response keys.
  static const String kStatus = 'status';
  static const String kText = 'text';
  static const String kTokenCount = 'tokenCount';
  static const String kDurationMs = 'durationMs';
  static const String kSuccess = 'success';
  static const String kErrorCode = 'errorCode';
  static const String kErrorMessage = 'errorMessage';

  /// Capability status values.
  static const String kStatusFull = 'full';
  static const String kStatusLimited = 'limited';
  static const String kStatusUnavailable = 'unavailable';
  static const String kStatusNeedsSetup = 'needsSetup';

  /// The method channel instance.
  static const MethodChannel channel = MethodChannel(name);
}
