import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_mode.freezed.dart';
part 'sleep_mode.g.dart';

enum SleepType {
  none,
  episode,
  time,
}

@freezed
class SleepMode with _$SleepMode {
  const factory SleepMode({
    required SleepType type,
    @Default(Duration.zero) Duration duration,
  }) = _SleepMode;

  factory SleepMode.fromJson(Map<String, dynamic> json) =>
      _$SleepModeFromJson(json);

  static const none = SleepMode(type: SleepType.none);
}

extension SleepExt on SleepMode {
  DateTime calcEndTime() => DateTime.now().add(duration);

  String getLabel(BuildContext context) {
    final l10n = L10n.of(context);
    switch (type) {
      case SleepType.none:
        return l10n.sleepOff;
      case SleepType.episode:
        return l10n.sleepOnEpisodeEnds;
      case SleepType.time:
        if (duration < const Duration(hours: 1)) {
          return l10n.sleepMin(duration.inMinutes);
        } else {
          return l10n.sleepHour(duration.inHours);
        }
    }
  }
}

const predefinedSleeps = <SleepMode>[
  SleepMode.none,
  SleepMode(type: SleepType.episode),
  SleepMode(type: SleepType.time, duration: Duration(minutes: 5)),
  SleepMode(type: SleepType.time, duration: Duration(minutes: 10)),
  SleepMode(type: SleepType.time, duration: Duration(minutes: 15)),
  SleepMode(type: SleepType.time, duration: Duration(minutes: 30)),
  SleepMode(type: SleepType.time, duration: Duration(minutes: 45)),
  SleepMode(type: SleepType.time, duration: Duration(hours: 1)),
  SleepMode(type: SleepType.time, duration: Duration(hours: 2)),
  SleepMode(type: SleepType.time, duration: Duration(hours: 3)),
];
