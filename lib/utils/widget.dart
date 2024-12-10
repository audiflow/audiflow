import 'package:flutter/scheduler.dart';

Future<void> tickNextFrame() async {
  await Future<void>.delayed(Duration.zero);
}

void onNextFrame(VoidCallback callback) {
  SchedulerBinding.instance.addPostFrameCallback((_) => callback());
}
