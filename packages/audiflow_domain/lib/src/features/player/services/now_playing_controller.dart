import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/now_playing_info.dart';

part 'now_playing_controller.g.dart';

/// Manages the currently playing episode metadata.
///
/// This controller is kept alive to maintain now playing state across
/// navigation and screen changes. The mini player uses this to display
/// episode information.
@Riverpod(keepAlive: true)
class NowPlayingController extends _$NowPlayingController {
  @override
  NowPlayingInfo? build() => null;

  /// Sets the currently playing episode metadata.
  void setNowPlaying(NowPlayingInfo info) {
    state = info;
  }

  /// Clears the now playing state when playback stops.
  void clear() {
    state = null;
  }

  /// Updates just the artwork URL (useful when artwork loads asynchronously).
  void updateArtworkUrl(String? artworkUrl) {
    if (state != null) {
      state = state!.copyWith(artworkUrl: artworkUrl);
    }
  }
}
