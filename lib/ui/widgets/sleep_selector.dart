// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seasoning/bloc/podcast/audio_bloc.dart';
import 'package:seasoning/bloc/settings/settings_bloc.dart';
import 'package:seasoning/entities/app_settings.dart';
import 'package:seasoning/entities/sleep.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/ui/widgets/slider_handle.dart';

/// This widget allows the user to change the playback speed and toggle audio effects.
///
/// The two audio effects, trim silence and volume boost, are currently Android only.
class SleepSelectorWidget extends StatefulWidget {
  const SleepSelectorWidget({
    super.key,
  });

  @override
  State<SleepSelectorWidget> createState() => _SleepSelectorWidgetState();
}

class _SleepSelectorWidgetState extends State<SleepSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    final settingsBloc = Provider.of<SettingsBloc>(context);
    final theme = Theme.of(context);

    return StreamBuilder<AppSettings>(
      stream: settingsBloc.settings,
      initialData: AppSettings.sensibleDefaults(),
      builder: (context, snapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              excludeFromSemantics: true,
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: theme.secondaryHeaderColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  builder: (context) {
                    return const SleepSlider();
                  },
                );
              },
              child: SizedBox(
                height: 48,
                width: 48,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.bedtime_outlined,
                      semanticLabel: L.of(context)!.sleep_timer_label,
                      size: 20,
                    ),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        isScrollControlled: true,
                        context: context,
                        backgroundColor: theme.secondaryHeaderColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        builder: (context) {
                          return const SleepSlider();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SleepSlider extends StatefulWidget {
  const SleepSlider({super.key});

  @override
  State<SleepSlider> createState() => _SleepSliderState();
}

class _SleepSliderState extends State<SleepSlider> {
  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);

    return StreamBuilder<Sleep>(
      stream: audioBloc.sleepStream,
      initialData: const Sleep(type: SleepType.none),
      builder: (context, snapshot) {
        final s = snapshot.data;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SliderHandle(),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                L.of(context)!.sleep_timer_label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (s != null && s.type == SleepType.none)
              Text(
                '(${L.of(context)!.sleep_off_label})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (s != null && s.type == SleepType.time)
              Text(
                '(${_formatDuration(s.timeRemaining)})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (s != null && s.type == SleepType.episode)
              Text(
                '(${L.of(context)!.sleep_episode_label})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                shrinkWrap: true,
                children: [
                  SleepSelectorEntry(
                    sleep: const Sleep(type: SleepType.none),
                    current: s,
                  ),
                  const Divider(),
                  SleepSelectorEntry(
                    sleep: const Sleep(
                      type: SleepType.time,
                      duration: Duration(minutes: 5),
                    ),
                    current: s,
                  ),
                  const Divider(),
                  SleepSelectorEntry(
                    sleep: const Sleep(
                      type: SleepType.time,
                      duration: Duration(minutes: 10),
                    ),
                    current: s,
                  ),
                  const Divider(),
                  SleepSelectorEntry(
                    sleep: const Sleep(
                      type: SleepType.time,
                      duration: Duration(minutes: 15),
                    ),
                    current: s,
                  ),
                  const Divider(),
                  SleepSelectorEntry(
                    sleep: const Sleep(
                      type: SleepType.time,
                      duration: Duration(minutes: 30),
                    ),
                    current: s,
                  ),
                  const Divider(),
                  SleepSelectorEntry(
                    sleep: const Sleep(
                      type: SleepType.time,
                      duration: Duration(minutes: 45),
                    ),
                    current: s,
                  ),
                  const Divider(),
                  SleepSelectorEntry(
                    sleep: const Sleep(
                      type: SleepType.time,
                      duration: Duration(minutes: 60),
                    ),
                    current: s,
                  ),
                  const Divider(),
                  SleepSelectorEntry(
                    sleep: const Sleep(
                      type: SleepType.episode,
                    ),
                    current: s,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return '$n';
      return '0$n';
    }

    final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}

class SleepSelectorEntry extends StatelessWidget {
  const SleepSelectorEntry({
    super.key,
    required this.sleep,
    required this.current,
  });

  final Sleep sleep;
  final Sleep? current;

  @override
  Widget build(BuildContext context) {
    final audioBloc = Provider.of<AudioBloc>(context, listen: false);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        audioBloc.sleep(
          Sleep(
            type: sleep.type,
            duration: sleep.duration,
          ),
        );

        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (sleep.type == SleepType.none)
              Text(
                L.of(context)!.sleep_off_label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (sleep.type == SleepType.time)
              Text(
                L
                    .of(context)!
                    .sleep_minute_label(sleep.duration.inMinutes.toString()),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (sleep.type == SleepType.episode)
              Text(
                L.of(context)!.sleep_episode_label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (sleep == current)
              const Icon(
                Icons.check,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
