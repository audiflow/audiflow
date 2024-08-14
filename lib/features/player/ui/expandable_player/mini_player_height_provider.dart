import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mini_player_height_provider.g.dart';

final miniPlayerExpandProgress = ValueNotifier<double>(0);

@Riverpod(keepAlive: true)
double miniPlayerHeight(MiniPlayerHeightRef ref) {
  void onValueChange() {
    ref.state = miniPlayerExpandProgress.value;
  }

  miniPlayerExpandProgress.addListener(onValueChange);
  ref.onDispose(() => miniPlayerExpandProgress.removeListener(onValueChange));
  return miniPlayerExpandProgress.value;
}
