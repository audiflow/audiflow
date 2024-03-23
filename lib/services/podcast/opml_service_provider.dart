// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/services/podcast/mobile_opml_service.dart';
import 'package:audiflow/services/podcast/opml_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/services/podcast/opml_service.dart';

part 'opml_service_provider.g.dart';

@riverpod
OPMLService opmlService(OpmlServiceRef ref) {
  return MobileOPMLService(ref);
}
