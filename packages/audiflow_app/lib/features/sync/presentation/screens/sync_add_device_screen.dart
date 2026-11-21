import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/sync_view_providers.dart';

/// Shows the account's QR code for another device to scan, and the
/// recovery code behind a tap (plan P7).
class SyncAddDeviceScreen extends ConsumerStatefulWidget {
  const SyncAddDeviceScreen({super.key});

  @visibleForTesting
  static const qrKey = ValueKey('syncAddDeviceQr');

  @visibleForTesting
  static const recoveryCodeKey = ValueKey('syncAddDeviceRecoveryCode');

  @override
  ConsumerState<SyncAddDeviceScreen> createState() =>
      _SyncAddDeviceScreenState();
}

class _SyncAddDeviceScreenState extends ConsumerState<SyncAddDeviceScreen> {
  // Hidden until asked for: the code is as good as the QR, and harder to
  // notice over a shoulder once shown.
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Rebuilt on status changes so a turn-off elsewhere hides the codes.
    ref.watch(syncStatusProvider);
    final credentials = ref.watch(syncControllerProvider).credentials;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncAddDevice)),
      body: credentials == null
          ? const SizedBox.shrink()
          : _body(context, l10n, credentials),
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations l10n,
    SyncCredentials credentials,
  ) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: LayoutConstants.contentMaxWidth,
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screenHorizontal,
            Spacing.lg,
            Spacing.screenHorizontal,
            Spacing.xl,
          ),
          children: [
            Center(
              child: DecoratedBox(
                // White behind the code in dark mode too: scanners expect
                // dark modules on a light ground.
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorders.groupedSurface,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: QrImageView(
                    key: SyncAddDeviceScreen.qrKey,
                    data: PairingCodec.encodeQr(credentials),
                    size: 240,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              l10n.syncQrInstructions,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.inkSecondary,
              ),
            ),
            const SizedBox(height: Spacing.xl),
            GroupedSectionHeader(text: l10n.syncRecoveryCodeHeader),
            if (_showCode)
              _RecoveryCode(code: PairingCodec.encodeRecoveryCode(credentials))
            else
              OutlinedButton.icon(
                onPressed: () => setState(() => _showCode = true),
                icon: const Icon(Icons.visibility_outlined),
                label: Text(l10n.syncRecoveryCodeShow),
              ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.syncRecoveryCodeWarning,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.inkTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryCode extends StatelessWidget {
  const _RecoveryCode({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // Four groups to a line, so the 20 groups read as 5 even rows.
    final groups = code.split('-');
    final lines = <String>[
      for (var i = 0; i < groups.length; i += 4)
        groups.skip(i).take(4).join('  '),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppBorders.groupedSurface,
        boxShadow: AppShadows.groupedSurface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: SelectableText(
          lines.join('\n'),
          key: SyncAddDeviceScreen.recoveryCodeKey,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'monospace',
            fontFeatures: const [FontFeature.tabularFigures()],
            height: 1.6,
            color: colors.ink,
          ),
        ),
      ),
    );
  }
}
