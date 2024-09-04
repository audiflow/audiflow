import 'package:audiflow/common/service/error_manager.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ErrorNotifier extends HookConsumerWidget {
  const ErrorNotifier({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(errorManagerProvider).whenData((error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    });
    return const SizedBox.shrink();
  }
}
