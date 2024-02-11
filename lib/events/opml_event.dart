// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

abstract class OPMLActionEvent {}

class OPMLNoneEvent extends OPMLActionEvent {}

class OPMLParsingEvent extends OPMLActionEvent {}

class OPMLLoadingEvent extends OPMLActionEvent {
  OPMLLoadingEvent({
    this.current,
    this.total,
    this.podcast,
  });

  final int? current;
  final int? total;
  final String? podcast;
}

class OPMLCompletedEvent extends OPMLActionEvent {}

class OPMLErrorEvent extends OPMLActionEvent {}

abstract class OPMLEvent {}

class OPMLImportEvent extends OPMLEvent {
  OPMLImportEvent({
    this.file,
  });

  final String? file;
}

class OPMLExportEvent extends OPMLEvent {}

class OPMLCancelEvent extends OPMLEvent {}
