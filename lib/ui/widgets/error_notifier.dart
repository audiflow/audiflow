import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/errors/errors.dart';
import 'package:seasoning/services/error/error_manager.dart';

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
