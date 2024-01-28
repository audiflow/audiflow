import 'dart:async';

import 'package:coten_player/bloc/bloc.dart';
import 'package:coten_player/entities/season.dart';
import 'package:coten_player/services/audio/audio_player_service.dart';
import 'package:coten_player/services/podcast/podcast_service.dart';
import 'package:coten_player/state/bloc_state.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// The BLoC provides access to [Season] details outside the direct scope
/// of a [Podcast].
class SeasonBloc extends Bloc {
  final log = Logger('SeasonBloc');
  final PodcastService podcastService;
  final AudioPlayerService audioPlayerService;

  /// Add to sink to fetch list of current seasons.
  final BehaviorSubject<bool> _seasonsInput = BehaviorSubject<bool>();

  /// Stream of current seasons
  Stream<BlocState<List<Season>>>? _seasonsOutput;

  /// Cache of our currently downloaded seasons.
  List<Season>? _seasons;

  SeasonBloc({
    required this.podcastService,
    required this.audioPlayerService,
  }) {
    _init();
  }

  void _init() {
    _seasonsOutput = _seasonsInput.switchMap<BlocState<List<Season>>>(
        (bool silent) => _loadSeasons(silent));
  }

  Stream<BlocState<List<Season>>> _loadSeasons(bool silent) async* {
    if (!silent) {
      yield BlocLoadingState();
    }

    _seasons = await podcastService.loadSeasons();

    yield BlocPopulatedState<List<Season>>(results: _seasons);
  }

  void Function(bool) get fetchSeasons => _seasonsInput.add;

  Stream<BlocState<List<Season>>>? get seasons => _seasonsOutput;
}
