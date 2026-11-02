import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiflow_app/features/car/services/car_media_controls.dart';
import 'package:audiflow_app/features/car/services/car_playback.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

const _drawableDir = 'android/app/src/main/res/drawable';

/// The file behind a `drawable/<name>` reference. audio_service resolves the
/// name with getIdentifier(), and a miss throws while building the custom
/// action on every playback state update.
File _drawableFile(String androidIcon) =>
    File('$_drawableDir/${androidIcon.split('/').last}.xml');

const _values = (speed: 1.5, skipForwardSeconds: 30, skipBackwardSeconds: 15);

void main() {
  group('carSpeedControl', () {
    test('has a distinct existing icon for every car speed', () {
      final icons = [for (final s in carSpeeds) carSpeedControl(s).androidIcon];

      check(icons.toSet().length).equals(carSpeeds.length);
      for (final icon in icons) {
        check(because: icon, _drawableFile(icon).existsSync()).isTrue();
      }
    });

    test('falls back to a generic icon between the steps', () {
      final icon = carSpeedControl(1.3).androidIcon;

      check(icon).equals(carSpeedControl(0.7).androidIcon);
      check([
        for (final s in carSpeeds) carSpeedControl(s).androidIcon,
      ]).not((it) => it.contains(icon));
      check(_drawableFile(icon).existsSync()).isTrue();
    });

    test('tolerates a stored speed with binary rounding error', () {
      check(
        carSpeedControl(1.2 + 1e-12).androidIcon,
      ).equals(carSpeedControl(1.2).androidIcon);
    });

    test('labels the button with the current speed, also between steps', () {
      for (final speed in [...carSpeeds, 1.3]) {
        check(
          carSpeedControl(speed).label,
        ).equals(PlaybackSpeedScale.label(speed));
      }
    });

    test('sends the action the audio handler dispatches on', () {
      final control = carSpeedControl(1.0);

      check(control.action).equals(MediaAction.custom);
      check(control.customAction?.name).equals(carCycleSpeedAction);
    });
  });

  group('skip controls', () {
    test('has a distinct existing icon per selectable forward interval', () {
      const selectable = [10, 15, 30, 45, 60];
      final icons = [
        for (final s in selectable) carFastForwardControl(s).androidIcon,
      ];

      check(icons.toSet().length).equals(selectable.length);
      for (final icon in icons) {
        check(because: icon, _drawableFile(icon).existsSync()).isTrue();
      }
    });

    test('has a distinct existing icon per selectable backward interval', () {
      const selectable = [10, 15, 30];
      final icons = [
        for (final s in selectable) carRewindControl(s).androidIcon,
      ];

      check(icons.toSet().length).equals(selectable.length);
      for (final icon in icons) {
        check(because: icon, _drawableFile(icon).existsSync()).isTrue();
      }
    });

    test('falls back to the plain arrows for a value without an icon', () {
      check(carFastForwardControl(20)).equals(MediaControl.fastForward);
      check(carRewindControl(45)).equals(MediaControl.rewind);
    });

    test('keeps the standard actions so the handler still receives them', () {
      check(carFastForwardControl(30).action).equals(MediaAction.fastForward);
      check(carRewindControl(10).action).equals(MediaAction.rewind);
    });
  });

  group('nowPlayingMediaControls', () {
    List<MediaAction> actions(List<MediaControl> controls) => [
      for (final control in controls) control.action,
    ];

    test('puts speed before stop, which is the last to give way', () {
      check(
        actions(
          nowPlayingMediaControls(
            playing: true,
            values: _values,
            includeSpeed: true,
          ),
        ),
      ).deepEquals([
        MediaAction.skipToPrevious,
        MediaAction.rewind,
        MediaAction.pause,
        MediaAction.fastForward,
        MediaAction.skipToNext,
        MediaAction.custom,
        MediaAction.stop,
      ]);
    });

    test('shows play while paused, with the speed still on it', () {
      final controls = nowPlayingMediaControls(
        playing: false,
        values: _values,
        includeSpeed: true,
      );

      check(actions(controls)).contains(MediaAction.play);
      check(controls).contains(carSpeedControl(_values.speed));
    });

    test('uses the icons for the given values', () {
      final controls = nowPlayingMediaControls(
        playing: true,
        values: _values,
        includeSpeed: true,
      );

      check(controls)
        ..contains(carFastForwardControl(_values.skipForwardSeconds))
        ..contains(carRewindControl(_values.skipBackwardSeconds))
        ..contains(carSpeedControl(_values.speed));
    });

    test('leaves the speed out where the car has its own button', () {
      check(
        actions(
          nowPlayingMediaControls(
            playing: true,
            values: _values,
            includeSpeed: false,
          ),
        ),
      ).not((it) => it.contains(MediaAction.custom));
    });

    test('publishes the plain controls until the values are known', () {
      final controls = nowPlayingMediaControls(
        playing: true,
        values: null,
        includeSpeed: true,
      );

      check(controls)
        ..contains(MediaControl.rewind)
        ..contains(MediaControl.fastForward);
      check(actions(controls)).not((it) => it.contains(MediaAction.custom));
    });
  });
}
