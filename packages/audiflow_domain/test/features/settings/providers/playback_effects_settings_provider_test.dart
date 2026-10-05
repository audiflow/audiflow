import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/fake_app_settings_repository.dart';

class _FailingSettingsRepository extends FakeAppSettingsRepository {
  @override
  Future<void> setVoiceBoost(bool enabled) async =>
      throw StateError('write failed');
}

/// Fails silence skipping writes once [gate] completes.
class _SlowFailingSkipSilenceRepository extends FakeAppSettingsRepository {
  final gate = Completer<void>();

  @override
  Future<void> setSkipSilence(bool enabled) async {
    await gate.future;
    throw StateError('write failed');
  }
}

void main() {
  late FakeAppSettingsRepository repo;
  late ProviderContainer container;

  ProviderContainer createContainer(FakeAppSettingsRepository repository) {
    return ProviderContainer(
      overrides: [appSettingsRepositoryProvider.overrideWithValue(repository)],
    );
  }

  setUp(() {
    repo = FakeAppSettingsRepository()..skipSilence = true;
    container = createContainer(repo);
  });

  tearDown(() => container.dispose());

  PlaybackEffects state() =>
      container.read(playbackEffectsSettingsControllerProvider);

  PlaybackEffectsSettingsController notifier() =>
      container.read(playbackEffectsSettingsControllerProvider.notifier);

  test('seeds state from the repository', () {
    check(
      state(),
    ).equals(const PlaybackEffects(skipSilence: true, voiceBoost: false));
  });

  test('save updates memory and persists each effect', () async {
    await notifier().save(PlaybackEffect.voiceBoost, enabled: true);
    await notifier().save(PlaybackEffect.skipSilence, enabled: false);

    check(
      state(),
    ).equals(const PlaybackEffects(skipSilence: false, voiceBoost: true));
    check(repo.voiceBoost).isTrue();
    check(repo.skipSilence).isFalse();
  });

  test('a failed write restores the previous state', () async {
    container.dispose();
    container = createContainer(_FailingSettingsRepository());

    await check(
      notifier().save(PlaybackEffect.voiceBoost, enabled: true),
    ).throws<StateError>();

    check(state()).equals(PlaybackEffects.off);
  });

  test('a failed write keeps the other effect toggled meanwhile', () async {
    container.dispose();
    final slow = _SlowFailingSkipSilenceRepository();
    container = createContainer(slow);

    final skip = check(
      notifier().save(PlaybackEffect.skipSilence, enabled: true),
    ).throws<StateError>();
    await notifier().save(PlaybackEffect.voiceBoost, enabled: true);
    slow.gate.complete();
    await skip;

    // Memory matches what a restart would read.
    check(
      state(),
    ).equals(const PlaybackEffects(skipSilence: false, voiceBoost: true));
    check(slow.voiceBoost).isTrue();
  });
}
