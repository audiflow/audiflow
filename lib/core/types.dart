import 'package:audiflow/entities/entities.dart';
import 'package:flutter/widgets.dart';

/// The order in which episodes are played.
enum PlayOrder {
  /// Play episodes in ascending order.
  timeAscend,

  /// Play episodes in descending order.
  timeDescend,
}

class PlayButtonTappedNotification extends Notification {
  PlayButtonTappedNotification(this.episode, {this.index});

  final Episode episode;
  final int? index;
}
