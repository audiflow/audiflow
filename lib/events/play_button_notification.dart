import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter/widgets.dart';

class PlayButtonTappedNotification extends Notification {
  PlayButtonTappedNotification(
    this.episode, {
    this.index,
  });

  final Episode episode;
  final int? index;
}
