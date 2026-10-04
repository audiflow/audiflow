import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../services/audio_route_channel.dart';

/// Opens the OS audio output picker (speaker, Bluetooth, AirPlay).
///
/// Only build this where [audioOutputPickerAvailableProvider] is true.
class AudioOutputPickerButton extends StatelessWidget {
  const AudioOutputPickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? const _IosRoutePicker()
        : const _AndroidOutputSwitcherButton();
  }
}

class _AndroidOutputSwitcherButton extends ConsumerWidget {
  const _AndroidOutputSwitcherButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context).playerAudioOutputLabel,
      icon: const Icon(Symbols.media_output),
      onPressed: () => unawaited(_openPicker(context, ref)),
    );
  }

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).playerAudioOutputUnavailable;
    final opened = await ref.read(audioRouteChannelProvider).showPicker();
    if (opened) return;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Flutter-drawn icon under a transparent native `AVRoutePickerView`.
///
/// iOS offers no API to open the route picker programmatically, so the
/// native view must receive the tap itself; drawing the icon in Flutter
/// keeps it consistent with the other action row buttons.
class _IosRoutePicker extends StatelessWidget {
  const _IosRoutePicker();

  // Matches the default IconButton tap target of the neighboring slots.
  static const _size = 48.0;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).playerAudioOutputLabel;
    return SizedBox.square(
      dimension: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The native view carries the accessibility label and action.
          ExcludeSemantics(
            // Same color as a Material 3 IconButton in the other slots.
            child: Icon(
              Symbols.airplay,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Positioned.fill(
            child: UiKitView(
              viewType: audioRoutePickerViewType,
              creationParams: {'label': label},
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
        ],
      ),
    );
  }
}
