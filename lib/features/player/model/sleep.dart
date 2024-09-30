import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep.freezed.dart';
part 'sleep.g.dart';

enum SleepType {
  none,
  episode,
  time,
}

@freezed
class Sleep with _$Sleep {
  const factory Sleep({
    required SleepType type,
    @Default(Duration.zero) Duration duration,
  }) = _Sleep;

  factory Sleep.fromJson(Map<String, dynamic> json) => _$SleepFromJson(json);
}

extension SleepExt on Sleep {
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

const predefinedSleeps = <Sleep>[
  Sleep(type: SleepType.none),
  Sleep(type: SleepType.episode),
  Sleep(type: SleepType.time, duration: Duration(minutes: 5)),
  Sleep(type: SleepType.time, duration: Duration(minutes: 10)),
  Sleep(type: SleepType.time, duration: Duration(minutes: 15)),
  Sleep(type: SleepType.time, duration: Duration(minutes: 30)),
  Sleep(type: SleepType.time, duration: Duration(minutes: 45)),
  Sleep(type: SleepType.time, duration: Duration(hours: 1)),
  Sleep(type: SleepType.time, duration: Duration(hours: 2)),
  Sleep(type: SleepType.time, duration: Duration(hours: 3)),
];
