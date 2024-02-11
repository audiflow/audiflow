// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/bloc/bloc.dart';
import 'package:seasoning/events/opml_event.dart';
import 'package:seasoning/services/podcast/opml_service.dart';

/// OPML (Outline Processor Markup Language) is an XML format for outlines, which is used in Podcast
/// apps for transferring podcast subscriptions/follows from/to other podcast apps.
///
/// Anytime supports both import and export of OPML.
class OPMLBloc extends Bloc {
  OPMLBloc({required this.opmlService}) {
    _listenOpmlEvents();
  }
  final log = Logger('OPMLBloc');

  final PublishSubject<OPMLEvent> _opmlEvent = PublishSubject<OPMLEvent>();
  final PublishSubject<OPMLActionEvent> _opmlState =
      PublishSubject<OPMLActionEvent>();
  final OPMLService opmlService;

  void _listenOpmlEvents() {
    _opmlEvent.listen((event) {
      if (event is OPMLImportEvent) {
        if (event.file != null) {
          opmlService.loadOPMLFile(event.file!).listen(_opmlState.add);
        }
      } else if (event is OPMLExportEvent) {
        opmlService.saveOPMLFile().listen(_opmlState.add);
      } else if (event is OPMLCancelEvent) {
        opmlService.cancel();
      }
    });
  }

  void Function(OPMLEvent) get opmlEvent => _opmlEvent.add;

  Stream<OPMLActionEvent> get opmlState => _opmlState.stream;
}
