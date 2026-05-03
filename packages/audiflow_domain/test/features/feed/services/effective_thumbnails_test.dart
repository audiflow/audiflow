import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

SmartPlaylistDefinition _playlist({bool? groupShow, bool? episodeShow}) =>
    SmartPlaylistDefinition(
      id: 'main',
      displayName: 'Main',
      grouping: const GroupingConfig(by: 'seasonNumber'),
      priority: 0,
      groupItem: groupShow != null
          ? GroupItemConfig(showThumbnail: groupShow)
          : null,
      episodeItem: episodeShow != null
          ? EpisodeItemConfig(showThumbnail: episodeShow)
          : null,
    );

SmartPlaylistGroupDef _group({bool? groupShow, bool? episodeShow}) =>
    SmartPlaylistGroupDef(
      id: 'g',
      displayName: 'G',
      groupItem: groupShow != null
          ? GroupItemConfig(showThumbnail: groupShow)
          : null,
      episodeItem: episodeShow != null
          ? EpisodeItemConfig(showThumbnail: episodeShow)
          : null,
    );

void main() {
  group('EffectiveThumbnails.podcastEpisodeList', () {
    test('null defaults true', () {
      expect(EffectiveThumbnails.podcastEpisodeList(), isTrue);
    });

    test('explicit true returns true', () {
      expect(
        EffectiveThumbnails.podcastEpisodeList(showEpisodeThumbnail: true),
        isTrue,
      );
    });

    test('explicit false returns false', () {
      expect(
        EffectiveThumbnails.podcastEpisodeList(showEpisodeThumbnail: false),
        isFalse,
      );
    });
  });

  group('EffectiveThumbnails.groupCard', () {
    test('all unset defaults true', () {
      expect(EffectiveThumbnails.groupCard(playlist: _playlist()), isTrue);
    });

    test('meta=false, no overrides → false', () {
      expect(
        EffectiveThumbnails.groupCard(
          showEpisodeThumbnail: false,
          playlist: _playlist(),
        ),
        isFalse,
      );
    });

    test('meta=true, no overrides → true', () {
      expect(
        EffectiveThumbnails.groupCard(
          showEpisodeThumbnail: true,
          playlist: _playlist(),
        ),
        isTrue,
      );
    });

    test('meta=false, playlist override true → true', () {
      expect(
        EffectiveThumbnails.groupCard(
          showEpisodeThumbnail: false,
          playlist: _playlist(groupShow: true),
        ),
        isTrue,
      );
    });

    test('meta=false, group override true → true', () {
      expect(
        EffectiveThumbnails.groupCard(
          showEpisodeThumbnail: false,
          playlist: _playlist(),
          group: _group(groupShow: true),
        ),
        isTrue,
      );
    });

    test('meta=true, group override false → false', () {
      expect(
        EffectiveThumbnails.groupCard(
          showEpisodeThumbnail: true,
          playlist: _playlist(),
          group: _group(groupShow: false),
        ),
        isFalse,
      );
    });

    test('group beats playlist', () {
      expect(
        EffectiveThumbnails.groupCard(
          playlist: _playlist(groupShow: true),
          group: _group(groupShow: false),
        ),
        isFalse,
      );
    });
  });

  group('EffectiveThumbnails.episodeRowInGroup', () {
    test('all unset defaults true', () {
      expect(
        EffectiveThumbnails.episodeRowInGroup(playlist: _playlist()),
        isTrue,
      );
    });

    test('meta=false, no overrides → false', () {
      expect(
        EffectiveThumbnails.episodeRowInGroup(
          showEpisodeThumbnail: false,
          playlist: _playlist(),
        ),
        isFalse,
      );
    });

    test('meta=false, playlist episodeItem true → true', () {
      expect(
        EffectiveThumbnails.episodeRowInGroup(
          showEpisodeThumbnail: false,
          playlist: _playlist(episodeShow: true),
        ),
        isTrue,
      );
    });

    test('meta=false, group episodeItem true → true', () {
      expect(
        EffectiveThumbnails.episodeRowInGroup(
          showEpisodeThumbnail: false,
          playlist: _playlist(),
          group: _group(episodeShow: true),
        ),
        isTrue,
      );
    });

    test('group beats playlist', () {
      expect(
        EffectiveThumbnails.episodeRowInGroup(
          playlist: _playlist(episodeShow: true),
          group: _group(episodeShow: false),
        ),
        isFalse,
      );
    });
  });

  group('independence between surfaces', () {
    test(
      'group.groupItem.showThumbnail=false does not affect episode rows',
      () {
        final playlist = _playlist();
        final group = _group(groupShow: false);

        expect(
          EffectiveThumbnails.groupCard(playlist: playlist, group: group),
          isFalse,
        );
        expect(
          EffectiveThumbnails.episodeRowInGroup(
            playlist: playlist,
            group: group,
          ),
          isTrue,
        );
      },
    );

    test(
      'group.episodeItem.showThumbnail=false does not affect group card',
      () {
        final playlist = _playlist();
        final group = _group(episodeShow: false);

        expect(
          EffectiveThumbnails.episodeRowInGroup(
            playlist: playlist,
            group: group,
          ),
          isFalse,
        );
        expect(
          EffectiveThumbnails.groupCard(playlist: playlist, group: group),
          isTrue,
        );
      },
    );
  });
}
