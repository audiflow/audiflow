// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_handler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Initializes AudioService with [AudiflowAudioHandler] and sets up
/// media item sync listeners.
///
/// Playback state is synced via direct stream piping inside the handler.
/// This provider only handles media item (now playing info) sync.
///
/// Must be awaited before the app starts to ensure platform media
/// controls are connected.

@ProviderFor(audioHandler)
final audioHandlerProvider = AudioHandlerProvider._();

/// Initializes AudioService with [AudiflowAudioHandler] and sets up
/// media item sync listeners.
///
/// Playback state is synced via direct stream piping inside the handler.
/// This provider only handles media item (now playing info) sync.
///
/// Must be awaited before the app starts to ensure platform media
/// controls are connected.

final class AudioHandlerProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudiflowAudioHandler>,
          AudiflowAudioHandler,
          FutureOr<AudiflowAudioHandler>
        >
    with
        $FutureModifier<AudiflowAudioHandler>,
        $FutureProvider<AudiflowAudioHandler> {
  /// Initializes AudioService with [AudiflowAudioHandler] and sets up
  /// media item sync listeners.
  ///
  /// Playback state is synced via direct stream piping inside the handler.
  /// This provider only handles media item (now playing info) sync.
  ///
  /// Must be awaited before the app starts to ensure platform media
  /// controls are connected.
  AudioHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioHandlerHash();

  @$internal
  @override
  $FutureProviderElement<AudiflowAudioHandler> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AudiflowAudioHandler> create(Ref ref) {
    return audioHandler(ref);
  }
}

String _$audioHandlerHash() => r'78c96d93c875c06213df9b05f72259964ad64586';
