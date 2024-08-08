import 'dart:io';

import 'package:audiflow/events/opml_event.dart';
import 'package:audiflow/features/browser/common/data/podcast_stats_repository/podcast_stats_repository.dart';
import 'package:audiflow/features/feed/service/podcast_service.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

export 'package:audiflow/features/feed/service/opml_service.dart';

part 'opml_service.g.dart';

@riverpod
OPMLService opmlService(OpmlServiceRef ref) {
  return OPMLService(ref);
}

/// This service handles the import and export of Podcasts via
/// the OPML format.
class OPMLService {
  OPMLService(this._ref);

  final Ref _ref;
  bool _process = false;

  PodcastService get _podcastService => _ref.read(podcastServiceProvider);

  PodcastStatsRepository get _podcastStatsRepository =>
      _ref.read(podcastStatsRepositoryProvider);

  OpmlEventStream get _opmlEventStream =>
      _ref.read(opmlEventStreamProvider.notifier);

  Future<void> loadOPMLFile(String file) async {
    _process = true;

    final opmlFile = File(file);
    final document = XmlDocument.parse(opmlFile.readAsStringSync());
    final outlines = document.findAllElements('outline');
    final pods = <OmplOutlineTag>[];

    for (final outline in outlines) {
      pods.add(OmplOutlineTag.parse(outline));
    }

    final total = pods.length;
    var current = 0;

    for (final p in pods) {
      if (!_process) {
        break;
      }
      _opmlEventStream.add(
        OPMLLoadingEvent(
          current: ++current,
          total: total,
          podcastTitle: p.text ?? '',
        ),
      );

      try {
        logger.d(() => 'Importing podcast ${p.xmlUrl}');

        // final result = await _podcastService.lookupPodcast(p.xmlUrl!);
        // if (result != null) {
        //   await _repository.subscribePodcast(result);
        // }
      } on Exception {
        logger.e(() => 'Failed to load podcast ${p.xmlUrl}');
      }
    }

    _opmlEventStream.add(OPMLCompletedEvent());
  }

  Future<void> saveOPMLFile() async {
    final subs = await _podcastStatsRepository.subscriptions();

    final builder = XmlBuilder()..processing('xml', 'version="1.0"');
    builder.element(
      'opml',
      attributes: {'version': '2.0'},
      nest: () {
        builder
          ..element(
            'head',
            nest: () {
              builder
                ..element(
                  'title',
                  nest: () {
                    builder.text('audiflow Subscriptions');
                  },
                )
                ..element(
                  'dateCreated',
                  nest: () {
                    final n = DateTime.now().toUtc();
                    final f =
                        DateFormat('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'').format(n);
                    builder.text(f);
                  },
                );
            },
          )
          ..element(
            'body',
            nest: () {
              for (final sub in subs) {
                builder.element(
                  'outline',
                  nest: () {
                    // builder
                    //   ..attribute('text', sub.$1.title)
                    //   ..attribute('xmlUrl', sub.$1.feedUrl);
                  },
                );
              }
            },
          );
      },
    );

    final export = builder.buildDocument();

    final output = Platform.isAndroid
        ? (await getExternalStorageDirectory())!
        : await getApplicationDocumentsDirectory();
    final outputFile = '${output.path}/audiflow_export.opml';
    File(outputFile).writeAsStringSync(export.toXmlString(pretty: true));

    await Share.shareXFiles(
      [XFile(outputFile)],
      text: 'audiflow OPML',
    );

    _opmlEventStream.add(OPMLCompletedEvent());
  }

  void cancel() {
    _process = false;
  }
}

class OmplOutlineTag {
  OmplOutlineTag({
    this.text,
    this.xmlUrl,
  });

  factory OmplOutlineTag.parse(XmlElement element) {
    return OmplOutlineTag(
      text: element.getAttribute('text')?.trim(),
      xmlUrl: element.getAttribute('xmlUrl')?.trim(),
    );
  }

  final String? text;
  final String? xmlUrl;
}
