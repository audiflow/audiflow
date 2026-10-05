// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seek_undo_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Offers a temporary undo for seek jumps made from the player screen.
///
/// Only deliberate jumps (seek bar release, chapter tap, transcript tap) go
/// through [seekWithUndo]; skip buttons and system controls seek directly,
/// so they never show the pill. This is a thin layer over
/// [AudioPlayerController.seekNowPlaying] and leaves its internals alone.
///
/// Kept alive so a transcript tap, made while the artwork tab may be torn
/// down, still leaves the pill waiting when the listener swipes back.

@ProviderFor(SeekUndoController)
final seekUndoControllerProvider = SeekUndoControllerProvider._();

/// Offers a temporary undo for seek jumps made from the player screen.
///
/// Only deliberate jumps (seek bar release, chapter tap, transcript tap) go
/// through [seekWithUndo]; skip buttons and system controls seek directly,
/// so they never show the pill. This is a thin layer over
/// [AudioPlayerController.seekNowPlaying] and leaves its internals alone.
///
/// Kept alive so a transcript tap, made while the artwork tab may be torn
/// down, still leaves the pill waiting when the listener swipes back.
final class SeekUndoControllerProvider
    extends $NotifierProvider<SeekUndoController, SeekUndoState?> {
  /// Offers a temporary undo for seek jumps made from the player screen.
  ///
  /// Only deliberate jumps (seek bar release, chapter tap, transcript tap) go
  /// through [seekWithUndo]; skip buttons and system controls seek directly,
  /// so they never show the pill. This is a thin layer over
  /// [AudioPlayerController.seekNowPlaying] and leaves its internals alone.
  ///
  /// Kept alive so a transcript tap, made while the artwork tab may be torn
  /// down, still leaves the pill waiting when the listener swipes back.
  SeekUndoControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seekUndoControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seekUndoControllerHash();

  @$internal
  @override
  SeekUndoController create() => SeekUndoController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SeekUndoState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SeekUndoState?>(value),
    );
  }
}

String _$seekUndoControllerHash() =>
    r'067b4c30400897d5a03d79dfd98e80bc617290b2';

/// Offers a temporary undo for seek jumps made from the player screen.
///
/// Only deliberate jumps (seek bar release, chapter tap, transcript tap) go
/// through [seekWithUndo]; skip buttons and system controls seek directly,
/// so they never show the pill. This is a thin layer over
/// [AudioPlayerController.seekNowPlaying] and leaves its internals alone.
///
/// Kept alive so a transcript tap, made while the artwork tab may be torn
/// down, still leaves the pill waiting when the listener swipes back.

abstract class _$SeekUndoController extends $Notifier<SeekUndoState?> {
  SeekUndoState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SeekUndoState?, SeekUndoState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SeekUndoState?, SeekUndoState?>,
              SeekUndoState?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
