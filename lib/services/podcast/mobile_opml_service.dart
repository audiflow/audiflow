// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/podcast/opml_event_stream_provider.dart';
import 'package:audiflow/services/podcast/opml_service.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

class MobileOPMLService extends OPMLService {
  MobileOPMLService(this._ref);

  final _log = Logger('MobileOPMLService');
  final Ref _ref;
  bool _process = false;

  PodcastService get _podcastService => _ref.read(podcastServiceProvider);

  Repository get _repository => _ref.read(repositoryProvider);

  OpmlEventStream get _opmlEventStream =>
      _ref.read(opmlEventStreamProvider.notifier);

  @override
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
        _log.fine('Importing podcast ${p.xmlUrl}');

        final result = await _podcastService.lookupPodcast(p.xmlUrl!);
        if (result != null) {
          await _repository.subscribePodcast(result);
        }
      } on Exception {
        _log.fine('Failed to load podcast ${p.xmlUrl}');
      }
    }

    _opmlEventStream.add(OPMLCompletedEvent());
  }

  @override
  Future<void> saveOPMLFile() async {
    final subs = await _repository.subscriptions();

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
                    builder
                      ..attribute('text', sub.$1.title)
                      ..attribute('xmlUrl', sub.$1.feedUrl);
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

  @override
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
