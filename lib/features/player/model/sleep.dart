import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep.freezed.dart';
part 'sleep.g.dart';

enum SleepType {
  none,
  time,
  episode,
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
  // Custom getter to calculate endTime based on current time and duration
  DateTime get endTime => DateTime.now().add(duration);
}
