import 'package:flutter/widgets.dart';
import 'package:seasoning/entities/entities.dart';

/// The order in which episodes are played.
enum PlayOrder {
  /// Play episodes in ascending order.
  timeAscend,

  /// Play episodes in descending order.
  timeDescend,
}

class PlayButtonTappedNotification extends Notification {
  PlayButtonTappedNotification(this.episode);

  final Episode episode;
}
