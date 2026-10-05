// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seek_undo_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Offers a temporary undo for seek jumps made from the player screen.
///
/// Only deliberate jumps made in view of the artwork (seek bar release,
/// chapter pick) go through [seekWithUndo]; skip buttons, transcript taps,
/// and system controls seek directly, so they never show the pill. This is
/// a thin layer over [AudioPlayerController.seekNowPlaying] and leaves its
/// internals alone.
///
/// Kept alive so the origin and its timer survive the artwork being torn
/// down and rebuilt (e.g. a tab switch) within the visible window.

@ProviderFor(SeekUndoController)
final seekUndoControllerProvider = SeekUndoControllerProvider._();

/// Offers a temporary undo for seek jumps made from the player screen.
///
/// Only deliberate jumps made in view of the artwork (seek bar release,
/// chapter pick) go through [seekWithUndo]; skip buttons, transcript taps,
/// and system controls seek directly, so they never show the pill. This is
/// a thin layer over [AudioPlayerController.seekNowPlaying] and leaves its
/// internals alone.
///
/// Kept alive so the origin and its timer survive the artwork being torn
/// down and rebuilt (e.g. a tab switch) within the visible window.
final class SeekUndoControllerProvider
    extends $NotifierProvider<SeekUndoController, SeekUndoState?> {
  /// Offers a temporary undo for seek jumps made from the player screen.
  ///
  /// Only deliberate jumps made in view of the artwork (seek bar release,
  /// chapter pick) go through [seekWithUndo]; skip buttons, transcript taps,
  /// and system controls seek directly, so they never show the pill. This is
  /// a thin layer over [AudioPlayerController.seekNowPlaying] and leaves its
  /// internals alone.
  ///
  /// Kept alive so the origin and its timer survive the artwork being torn
  /// down and rebuilt (e.g. a tab switch) within the visible window.
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
    r'219003392c9adafe6da14721e2cbab93a65423dc';

/// Offers a temporary undo for seek jumps made from the player screen.
///
/// Only deliberate jumps made in view of the artwork (seek bar release,
/// chapter pick) go through [seekWithUndo]; skip buttons, transcript taps,
/// and system controls seek directly, so they never show the pill. This is
/// a thin layer over [AudioPlayerController.seekNowPlaying] and leaves its
/// internals alone.
///
/// Kept alive so the origin and its timer survive the artwork being torn
/// down and rebuilt (e.g. a tab switch) within the visible window.

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
