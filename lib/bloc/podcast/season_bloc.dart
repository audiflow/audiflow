import 'dart:async';

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/bloc/bloc.dart';
import 'package:seasoning/entities/season.dart';
import 'package:seasoning/events/bloc_state.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';

/// The BLoC provides access to [Season] details outside the direct scope
/// of a [Podcast].
class SeasonBloc extends Bloc {

  SeasonBloc({
    required this.podcastService,
    required this.audioPlayerService,
  }) {
    _init();
  }
  final log = Logger('SeasonBloc');
  final PodcastService podcastService;
  final AudioPlayerService audioPlayerService;

  /// Add to sink to fetch list of current seasons.
  final BehaviorSubject<bool> _seasonsInput = BehaviorSubject<bool>();

  /// Stream of current seasons
  Stream<BlocState<List<Season>>>? _seasonsOutput;

  /// Cache of our currently downloaded seasons.
  List<Season>? _seasons;

  void _init() {
    _seasonsOutput = _seasonsInput.switchMap<BlocState<List<Season>>>(
        _loadSeasons,);
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
