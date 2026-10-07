import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Non-production preview of the redesign's shared components, used to
/// review them on a device before the screens that use them exist.
///
/// Sample strings are fixture content mirroring the design mockups, not
/// user-facing copy, so they are intentionally not localized.
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = _dark ? AppTheme.dark() : AppTheme.light();
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.developerDesignGalleryTitle),
          actions: [
            IconButton(
              tooltip: l10n.developerDesignGalleryToggleBrightness,
              icon: Icon(_dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _dark = !_dark),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
          children: const [
            _SettingsGroupsPreview(),
            SizedBox(height: Spacing.sectionGap),
            _PlayPillPreview(),
            SizedBox(height: Spacing.sectionGap),
            _ProgressRowsPreview(),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroupsPreview extends StatefulWidget {
  const _SettingsGroupsPreview();

  @override
  State<_SettingsGroupsPreview> createState() => _SettingsGroupsPreviewState();
}

class _SettingsGroupsPreviewState extends State<_SettingsGroupsPreview> {
  bool _perPodcast = true;
  bool _skipSilence = false;
  double _speed = 1.2;

  void _stepSpeed(double delta) {
    setState(() => _speed = ((_speed + delta) * 10).round() / 10);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GroupedSection(
          header: '再生',
          children: [
            SettingsRow(
              title: '再生順',
              trailing: const SettingsTrailing.picker(value: '古い順'),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: Spacing.sectionGap),
        _audioGroup(),
        const SizedBox(height: Spacing.sectionGap),
        const _AppSettingsGroup(),
      ],
    );
  }

  Widget _audioGroup() {
    return GroupedSection(
      header: 'オーディオ',
      footer: 'オンにすると、この番組だけ別の再生設定を使います。',
      children: [
        SettingsRow(
          title: 'この番組専用の設定',
          trailing: SettingsTrailing.toggle(
            value: _perPodcast,
            onChanged: (value) => setState(() => _perPodcast = value),
          ),
        ),
        SettingsRow(
          title: '再生速度',
          trailing: SettingsTrailing.stepper(
            valueLabel: '${_speed.toStringAsFixed(1)}x',
            decrementLabel: '遅く',
            incrementLabel: '速く',
            onDecrement: _speed <= 0.5 ? null : () => _stepSpeed(-0.1),
            onIncrement: 3.0 <= _speed ? null : () => _stepSpeed(0.1),
          ),
        ),
        SettingsRow(
          title: '無音をスキップ',
          trailing: SettingsTrailing.toggle(
            value: _skipSilence,
            onChanged: (value) => setState(() => _skipSilence = value),
          ),
        ),
        const SettingsRow(
          title: 'ボイスブースト（無効）',
          trailing: SettingsTrailing.toggle(value: false, onChanged: null),
        ),
      ],
    );
  }
}

class _AppSettingsGroup extends StatelessWidget {
  const _AppSettingsGroup();

  @override
  Widget build(BuildContext context) {
    const rows = [
      (Icons.palette_outlined, '外観', 'テーマ、文字サイズ'),
      (Icons.play_circle_outline, '再生', 'スキップ間隔、再生速度、中断時の動作'),
      (Icons.download_outlined, 'ダウンロード', '自動ダウンロード、保持する件数'),
      (Icons.sync, 'フィードの同期', '更新間隔、Wi-Fi のみ'),
    ];
    return GroupedSection(
      separatorIndent: SettingsRow.separatorIndentWithIcon,
      children: [
        for (final (icon, title, subtitle) in rows)
          SettingsRow(
            icon: icon,
            title: title,
            subtitle: subtitle,
            trailing: const SettingsTrailing.chevron(),
            onTap: () {},
          ),
      ],
    );
  }
}

class _PlayPillPreview extends StatelessWidget {
  const _PlayPillPreview();

  @override
  Widget build(BuildContext context) {
    return GroupedSection(
      header: 'PLAY PILL',
      children: [
        Padding(
          padding: const EdgeInsets.all(Spacing.rowHorizontal),
          child: Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              _pill('48分'),
              _pill('残り17分', isPlaying: true),
              _pill('再生済み', isCompleted: true),
              _pill('48分', isLoading: true),
              _pill(''),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(
    String label, {
    bool isPlaying = false,
    bool isLoading = false,
    bool isCompleted = false,
  }) {
    return EpisodePlayPill(
      label: label,
      isPlaying: isPlaying,
      isLoading: isLoading,
      isCompleted: isCompleted,
      onPressed: () {},
    );
  }
}

class _ProgressRowsPreview extends StatelessWidget {
  const _ProgressRowsPreview();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('未再生', null),
      ('途中まで再生（35%）', 0.35),
      ('もうすぐ終わり（92%）', 0.92),
      ('再生済み', 1.0),
    ];
    return GroupedSection(
      header: 'BOTTOM-EDGE PROGRESS',
      children: [
        for (final (title, fraction) in rows)
          BottomEdgeProgress(
            fraction: fraction,
            child: SettingsRow(title: title),
          ),
      ],
    );
  }
}
