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

// The values with a drawable: the choices in the playback settings. A stored
// value outside them falls back to a plain icon. `tool/generate_car_icons.py`
// generates the drawables and `res/raw/keep.xml` keeps them, because
// audio_service looks them up by name.
const _skipForwardIconSeconds = {10, 15, 30, 45, 60};
const _skipBackwardIconSeconds = {10, 15, 30};

/// Shown for a speed between [carSpeeds], set on the phone.
const _genericSpeedIcon = 'drawable/ic_car_speed';

String _speedIcon(double speed) {
  // Tolerance as in [nextCarSpeed]: a stored speed may not be the exact double.
  const epsilon = 1e-9;
  for (final step in carSpeeds) {
    if ((step - speed).abs() < epsilon) {
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
/// Android 13+ itself, and into a notification button below that.
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
/// [values] is null until the settings have been read, which only the first
/// state, before any session is active, can see. [includeSpeed] is for
/// Android: CarPlay has its own rate button.
///
/// The system fills its limited slots in this order, so speed comes after
/// the skip buttons, leaving the phone's media controls as they were, and
/// before stop, which is the first to give way on Android Auto.
List<MediaControl> nowPlayingMediaControls({
  required bool playing,
  required NowPlayingControlValues? values,
  required bool includeSpeed,
}) {
  return [
    MediaControl.skipToPrevious,
    if (values == null)
      MediaControl.rewind
    else
      carRewindControl(values.skipBackwardSeconds),
    if (playing) MediaControl.pause else MediaControl.play,
    if (values == null)
      MediaControl.fastForward
    else
      carFastForwardControl(values.skipForwardSeconds),
    MediaControl.skipToNext,
    if (values != null && includeSpeed) carSpeedControl(values.speed),
    MediaControl.stop,
  ];
}
