// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/events/opml_event.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/services/podcast/opml_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

class MobileOPMLService extends OPMLService {
  MobileOPMLService({
    required this.podcastService,
    required this.repository,
  });

  final log = Logger('MobileOPMLService');
  bool process = false;

  final PodcastService podcastService;
  final Repository repository;

  @override
  Stream<OPMLActionEvent> loadOPMLFile(String file) async* {
    yield OPMLParsingEvent();

    process = true;

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
      if (process) {
        yield OPMLLoadingEvent(
          current: ++current,
          total: total,
          podcast: p.text,
        );

        try {
          log.fine('Importing podcast ${p.xmlUrl}');

          final result = await podcastService.loadPodcast(
            podcast:
                Podcast(guid: '', link: '', title: p.text!, url: p.xmlUrl!),
            refresh: true,
          );

          if (result != null) {
            await podcastService.subscribe(result);
          }
        } on Exception {
          log.fine('Failed to load podcast ${p.xmlUrl}');
        }
      }
    }

    yield OPMLCompletedEvent();
  }

  @override
  Stream<OPMLActionEvent> saveOPMLFile() async* {
    final subs = await podcastService.subscriptions();

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
                    builder.text('Anytime Subscriptions');
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
                    builder
                      ..attribute('text', sub.title)
                      ..attribute('xmlUrl', sub.url);
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
    final outputFile = '${output.path}/anytime_export.opml';
    File(outputFile).writeAsStringSync(export.toXmlString(pretty: true));

    await Share.shareXFiles(
      [XFile(outputFile)],
      text: 'Anytime OPML',
    );

    yield OPMLCompletedEvent();
  }

  @override
  void cancel() {
    process = false;
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
