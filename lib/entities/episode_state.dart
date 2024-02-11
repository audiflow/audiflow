import 'package:freezed_annotation/freezed_annotation.dart';

part 'episode_state.freezed.dart';

/// A class that represents an instance of a episode.
///
/// When persisted to disk this represents a episode that is being followed.
@freezed
class EpisodeState with _$EpisodeState {
  const factory EpisodeState({
    @Default(false) bool chaptersLoading,
    @Default(false) bool highlight,
    @Default(false) bool queued,
    @Default(false) bool streaming,
  }) = _EpisodeState;
}

// extension EpisodeStateExt on EpisodeState {
//   bool get chaptersAreLoaded => !chaptersLoading && chapters.isNotEmpty;
//
//   bool get chaptersAreNotLoaded => chaptersLoading && chapters.isEmpty;
// }
