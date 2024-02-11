// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:seasoning/events/opml_event.dart';

/// This service handles the import and export of Podcasts via
/// the OPML format.
abstract class OPMLService {
  Stream<OPMLActionEvent> loadOPMLFile(String file);

  Stream<OPMLActionEvent> saveOPMLFile();

  void cancel();
}
