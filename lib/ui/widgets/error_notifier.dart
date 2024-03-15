// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/errors/errors.dart';
import 'package:audiflow/services/error/error_manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ErrorNotifier extends HookConsumerWidget {
  const ErrorNotifier({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(errorManagerProvider).whenData((error) {
      var message = '';
      switch (error.type) {
        case NetworkErrorType.connectivity:
          message = 'No connectivity';
        case NetworkErrorType.timeout:
          message = 'Network timeout';
        case NetworkErrorType.unknown:
          message = 'Network unknown error';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
    return const SizedBox.shrink();
  }
}
