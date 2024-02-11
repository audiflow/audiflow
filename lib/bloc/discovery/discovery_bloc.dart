// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:podcast_search/podcast_search.dart' as podcast_search;
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/bloc/bloc.dart';
import 'package:seasoning/bloc/discovery/discovery_state_event.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';

/// A BLoC to interact with the Discovery UI page and the [PodcastService] to
/// fetch the iTunes/PodcastIndex charts.
///
/// As charts will not change very frequently the results are cached for [cacheMinutes].
class DiscoveryBloc extends Bloc {

  DiscoveryBloc({required this.podcastService}) {
    _init();
  }
  static const cacheMinutes = 30;

  final log = Logger('DiscoveryBloc');
  final PodcastService podcastService;

  /// Takes an event which triggers a loading of chart data from the selected provider.
  final _discoveryInput = BehaviorSubject<DiscoveryEvent>();

  /// A stream of genres from the selected provider.
  final _genres = PublishSubject<List<String>>();

  /// The last genre to be passed in a [DiscoveryEvent].
  final _selectedGenre = BehaviorSubject<SelectedGenre>(sync: true);

  /// The last fetched results.
  Stream<DiscoveryState>? _discoveryResults;

  /// To save bandwidth we cache the results.
  podcast_search.SearchResult? _resultsCache;

  String _lastGenre = '';
  int _lastIndex = 0;

  void _init() {
    _discoveryResults = _discoveryInput
        .switchMap<DiscoveryState>(_charts);
    _selectedGenre.value = SelectedGenre(index: 0, genre: '');
    _genres.onListen = _loadGenres;
  }

  void _loadGenres() {
    _genres.sink.add(podcastService.genres());
  }

  Stream<DiscoveryState> _charts(DiscoveryEvent event) async* {
    yield DiscoveryLoadingState();

    if (event is DiscoveryChartEvent) {
      if (_resultsCache == null ||
          event.genre != _lastGenre ||
          DateTime.now().difference(_resultsCache!.processedTime).inMinutes >
              cacheMinutes) {
        _lastGenre = event.genre;
        _lastIndex = podcastService.genres().indexOf(_lastGenre);

        if (_lastIndex > 0) {
          _selectedGenre
              .add(SelectedGenre(index: _lastIndex, genre: _lastGenre));
        } else {
          /// Must have changed provider
          _lastGenre = '';
          _selectedGenre.add(SelectedGenre(index: 0, genre: ''));
        }
        _resultsCache = await podcastService.charts(
          size: event.count,
          genre: event.genre,
          countryCode: event.countryCode,
        );
      }

      yield DiscoveryPopulatedState<podcast_search.SearchResult>(
        genre: event.genre,
        index: podcastService.genres().indexOf(event.genre),
        results: _resultsCache,
      );
    }
  }

  @override
  void dispose() {
    _discoveryInput.close();
  }

  void Function(DiscoveryEvent) get discover => _discoveryInput.add;

  Stream<DiscoveryState>? get results => _discoveryResults;

  Stream<List<String>> get genres => _genres.stream;

  SelectedGenre get selectedGenre => _selectedGenre.value;
}

class SelectedGenre {

  SelectedGenre({
    required this.index,
    required this.genre,
  });
  final int index;
  final String genre;
}
