// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockPathProvider extends PathProviderPlatform {
  Future<Directory> getApplicationDocumentsDirectory() {
    return Future.value(Directory.systemTemp);
  }

  @override
  Future<String> getApplicationDocumentsPath() {
    return Future.value(Directory.systemTemp.path);
  }
}
