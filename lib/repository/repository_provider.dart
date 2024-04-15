// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/repository/isar_repository.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/repository/repository.dart';

part 'repository_provider.g.dart';

@Riverpod(keepAlive: true)
Repository repository(RepositoryRef ref) => IsarRepository();
