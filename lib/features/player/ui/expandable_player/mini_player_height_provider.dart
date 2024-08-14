import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mini_player_height_provider.g.dart';

const double playerMinHeight = 80;
const miniPlayerPercentageDeclaration = 0.2;
final miniPlayerExpandProgress = ValueNotifier<double>(0);

@Riverpod(keepAlive: true)
double miniPlayerHeight(MiniPlayerHeightRef ref) {
  void onValueChange() {
    ref.state = playerMinHeight * miniPlayerExpandProgress.value;
  }

  miniPlayerExpandProgress.addListener(onValueChange);
  ref.onDispose(() => miniPlayerExpandProgress.removeListener(onValueChange));
  return miniPlayerExpandProgress.value;
}
