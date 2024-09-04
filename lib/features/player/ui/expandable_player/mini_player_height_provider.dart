import 'package:audiflow/features/player/ui/expandable_player/expandable_player_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mini_player_height_provider.g.dart';

const double playerMinHeight = 80;
const miniPlayerPercentageDeclaration = 0.2;

@riverpod
double miniPlayerHeight(MiniPlayerHeightRef ref) {
  final expandablePlayerState = ref.watch(expandablePlayerControllerProvider);
  return expandablePlayerState.episode == null ? 0 : playerMinHeight;
}
