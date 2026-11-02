import 'package:audio_service/audio_service.dart';
import 'package:audiflow_core/audiflow_core.dart';

import 'car_playback.dart';

/// Name of the custom action behind Android Auto's speed button.
const carCycleSpeedAction = 'cycleSpeed';

/// The values Now Playing's controls show.
typedef NowPlayingControlValues = ({
  double speed,
  int skipForwardSeconds,
  int skipBackwardSeconds,
});

// The values with a drawable, which must cover `SkipIntervalChoices` (a test
// checks). Kept separate so a value without a drawable falls back to a plain
// icon rather than failing the name lookup. `tool/generate_car_icons.py`
// generates the drawables and `res/raw/keep.xml` keeps them, because
// audio_service looks them up by name.
const _skipForwardIconSeconds = {10, 15, 30, 45, 60};
const _skipBackwardIconSeconds = {10, 15, 30};

/// Shown for a speed between [carSpeeds], set on the phone.
const _genericSpeedIcon = 'drawable/ic_car_speed';

String _speedIcon(double speed) {
  for (final step in carSpeeds) {
    if ((step - speed).abs() < carSpeedEpsilon) {
      final name = step.toStringAsFixed(1).replaceAll('.', '_');
      return '${_genericSpeedIcon}_$name';
    }
  }
  return _genericSpeedIcon;
}

/// Android Auto's speed button. It draws no text on a button, so the icon
/// itself shows the speed; the label covers speeds without their own icon.
MediaControl carSpeedControl(double speed) => MediaControl.custom(
  androidIcon: _speedIcon(speed),
  label: PlaybackSpeedScale.label(speed),
  name: carCycleSpeedAction,
);

/// Fast forward, with an icon showing [seconds] when one exists.
///
/// Stays a standard action: audio_service turns it into a custom action on
/// Android 13+ itself, and into a notification button below that, where
/// Android Auto draws its own icon instead of this one.
MediaControl carFastForwardControl(int seconds) =>
    _skipForwardIconSeconds.contains(seconds)
    ? MediaControl.fastForward.copyWith(
        androidIcon: 'drawable/ic_car_forward_$seconds',
      )
    : MediaControl.fastForward;

/// Rewind, with an icon showing [seconds] when one exists.
MediaControl carRewindControl(int seconds) =>
    _skipBackwardIconSeconds.contains(seconds)
    ? MediaControl.rewind.copyWith(
        androidIcon: 'drawable/ic_car_rewind_$seconds',
      )
    : MediaControl.rewind;

/// The control set the media session publishes.
///
/// [values] stays null on iOS, where the system draws the buttons and
/// CarPlay has its own rate button, and on Android until the settings have
/// been read, before any session is active.
///
/// The system fills its limited slots in this order, so speed comes after
/// the skip buttons and before stop, so that stop is what gives way when the
/// slots run out.
///
/// With [values], previous and next are left out: the handler maps them to
/// the same skips as rewind and fast forward, and publishing them would only
/// add two more buttons doing the same thing to Android Auto's row. Hardware
/// next and previous keys do not depend on them, as audio_service forwards
/// those keys regardless of the published controls.
List<MediaControl> nowPlayingMediaControls({
  required bool playing,
  required NowPlayingControlValues? values,
}) {
  if (values == null) {
    return [
      MediaControl.skipToPrevious,
      MediaControl.rewind,
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.fastForward,
      MediaControl.skipToNext,
      MediaControl.stop,
    ];
  }
  return [
    carRewindControl(values.skipBackwardSeconds),
    if (playing) MediaControl.pause else MediaControl.play,
    carFastForwardControl(values.skipForwardSeconds),
    carSpeedControl(values.speed),
    MediaControl.stop,
  ];
}

/// Which of [nowPlayingMediaControls] the collapsed notification shows.
///
/// Null with [values] lets audio_service pick the first three native buttons:
/// rewind, play and fast forward below Android 13, and just play from 13 on,
/// where the other controls are custom actions. A fixed list could point past
/// the end of the shorter native list.
List<int>? nowPlayingCompactActionIndices({
  required NowPlayingControlValues? values,
}) => values == null ? _plainCompactActionIndices : null;

const _plainCompactActionIndices = [0, 2, 4];
