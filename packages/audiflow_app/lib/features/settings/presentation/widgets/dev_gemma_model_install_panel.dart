import 'dart:async';

import 'package:audiflow_ai/audiflow_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../voice/gemma/gemma_voice_providers.dart';

/// Debug-only inline panel that triggers the Gemma model download for the
/// currently selected variant.
///
/// Production has no UI to call [GemmaModelManager.ensureInstalled], so a
/// fresh install of the app would crash on the first hold-to-talk inside
/// `FlutterGemma.getActiveModel(...)`. This panel lets developers fetch the
/// model on-device for testing without shipping the full provisioning UX.
///
/// The panel is gated by [kDebugMode] at the call site; in release builds it
/// is never instantiated.
class DevGemmaModelInstallPanel extends ConsumerStatefulWidget {
  const DevGemmaModelInstallPanel({super.key, required this.variant});

  final GemmaModelVariant variant;

  @override
  ConsumerState<DevGemmaModelInstallPanel> createState() =>
      _DevGemmaModelInstallPanelState();
}

class _DevGemmaModelInstallPanelState
    extends ConsumerState<DevGemmaModelInstallPanel> {
  _DevState _state = const _Checking();

  @override
  void initState() {
    super.initState();
    unawaited(_refreshStatus());
  }

  @override
  void didUpdateWidget(covariant DevGemmaModelInstallPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A variant switch mid-download would mean the user changed their mind;
    // don't clobber an in-flight install with a status check, just let it
    // complete. On any other state, re-check for the new variant.
    if (oldWidget.variant != widget.variant && _state is! _Downloading) {
      unawaited(_refreshStatus());
    }
  }

  Future<void> _refreshStatus() async {
    setState(() => _state = const _Checking());
    try {
      final installed = await ref
          .read(gemmaModelManagerProvider)
          .isInstalled(widget.variant);
      if (!mounted) return;
      setState(
        () => _state = installed ? const _Installed() : const _NotInstalled(),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _state = _Failed('Status check failed: $e'));
    }
  }

  Future<void> _download() async {
    setState(() => _state = const _Downloading(0));
    try {
      await ref
          .read(gemmaModelManagerProvider)
          .ensureInstalled(
            widget.variant,
            onProgress: (percent) {
              if (!mounted) return;
              setState(() => _state = _Downloading(percent));
            },
          );
      if (!mounted) return;
      setState(() => _state = const _Installed());
    } on GemmaModelInstallException catch (e) {
      if (!mounted) return;
      setState(() => _state = _Failed('${e.phase.name}: ${e.cause}'));
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _state = _Failed('$e'));
    }
  }

  Future<void> _uninstall() async {
    setState(() => _state = const _Checking());
    try {
      await ref.read(gemmaModelManagerProvider).uninstall(widget.variant);
      if (!mounted) return;
      setState(() => _state = const _NotInstalled());
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _state = _Failed('Uninstall failed: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Symbols.bug_report, size: 16, color: cs.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Debug: model install',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: cs.tertiary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.variant.fileName} '
                '(~${widget.variant.approximateSizeMb} MB)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ..._statusBody(context),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _statusBody(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (_state) {
      _Checking() => const [LinearProgressIndicator()],
      _NotInstalled() => [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Symbols.download),
            label: const Text('Download model'),
            onPressed: _download,
          ),
        ),
      ],
      _Downloading(:final percent) => [
        LinearProgressIndicator(value: percent < 100 ? percent / 100 : null),
        const SizedBox(height: 6),
        Text('$percent%'),
      ],
      _Installed() => [
        Row(
          children: [
            Icon(Symbols.check_circle, color: cs.primary, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text('Installed', style: TextStyle(color: cs.primary)),
            ),
            TextButton(onPressed: _uninstall, child: const Text('Remove')),
          ],
        ),
      ],
      _Failed(:final message) => [
        Text(message, style: TextStyle(color: cs.error)),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _refreshStatus,
            child: const Text('Retry'),
          ),
        ),
      ],
    };
  }
}

sealed class _DevState {
  const _DevState();
}

class _Checking extends _DevState {
  const _Checking();
}

class _NotInstalled extends _DevState {
  const _NotInstalled();
}

class _Downloading extends _DevState {
  const _Downloading(this.percent);
  final int percent;
}

class _Installed extends _DevState {
  const _Installed();
}

class _Failed extends _DevState {
  const _Failed(this.message);
  final String message;
}
