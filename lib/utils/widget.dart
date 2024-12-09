import 'package:flutter/scheduler.dart';

void onNextFrame(VoidCallback callback) {
  SchedulerBinding.instance.addPostFrameCallback((_) => callback());
}
