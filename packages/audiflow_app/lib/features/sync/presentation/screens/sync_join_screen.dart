import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../widgets/sync_labels.dart';

/// Builds the camera view; calls `onCode` with each scanned QR payload.
typedef SyncScannerBuilder =
    Widget Function(BuildContext context, ValueChanged<String> onCode);

/// Joins the account another device shows: scan its QR code, or type the
/// recovery code (plan P7).
class SyncJoinScreen extends ConsumerStatefulWidget {
  const SyncJoinScreen({super.key, this.scannerBuilder = cameraScanner});

  /// Replaced in tests, where there is no camera.
  final SyncScannerBuilder scannerBuilder;

  static Widget cameraScanner(
    BuildContext context,
    ValueChanged<String> onCode,
  ) => _CameraScanner(onCode: onCode);

  @override
  ConsumerState<SyncJoinScreen> createState() => _SyncJoinScreenState();
}

class _SyncJoinScreenState extends ConsumerState<SyncJoinScreen> {
  // One confirmation at a time; the camera keeps reporting the same code.
  bool _busy = false;
  String? _lastInvalid;

  Future<void> _onScanned(String text) async {
    if (_busy || text == _lastInvalid) return;
    final SyncCredentials credentials;
    try {
      credentials = PairingCodec.decodeQr(text);
    } on FormatException {
      _lastInvalid = text;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.syncScanInvalid)));
      return;
    }
    await _join(credentials);
  }

  Future<void> _enterCode() async {
    if (_busy) return;
    final credentials = await showDialog<SyncCredentials>(
      context: context,
      builder: (_) => const _RecoveryCodeDialog(),
    );
    if (credentials == null || !mounted) return;
    await _join(credentials);
  }

  Future<void> _join(SyncCredentials credentials) async {
    _busy = true;
    try {
      final l10n = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.syncJoinConfirmTitle),
          content: Text(l10n.syncJoinConfirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.syncJoinAction),
            ),
          ],
        ),
      );
      if (!(confirmed ?? false) || !mounted) return;
      final joined = await runSyncAction(
        context,
        ref,
        (c) => c.join(credentials),
      );
      if (joined && mounted) context.go(AppRoutes.settingsDeviceSync);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.syncJoinTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutConstants.contentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.screenHorizontal),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: AppBorders.groupedSurface,
                          child: ColoredBox(
                            color: Colors.black,
                            child: widget.scannerBuilder(context, _onScanned),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    l10n.syncScanInstructions,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                  OutlinedButton(
                    onPressed: _enterCode,
                    child: Text(l10n.syncEnterCode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraScanner extends StatefulWidget {
  const _CameraScanner({required this.onCode});

  final ValueChanged<String> onCode;

  @override
  State<_CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<_CameraScanner> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        for (final barcode in capture.barcodes) {
          final value = barcode.rawValue;
          if (value != null) widget.onCode(value);
        }
      },
      errorBuilder: (context, _) => Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Center(
          child: Text(
            AppLocalizations.of(context).syncCameraUnavailable,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _RecoveryCodeDialog extends StatefulWidget {
  const _RecoveryCodeDialog();

  @override
  State<_RecoveryCodeDialog> createState() => _RecoveryCodeDialogState();
}

class _RecoveryCodeDialogState extends State<_RecoveryCodeDialog> {
  final _text = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    try {
      Navigator.pop(context, PairingCodec.decodeRecoveryCode(_text.text));
    } on FormatException {
      setState(
        () => _error = AppLocalizations.of(context).syncEnterCodeInvalid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.syncEnterCode),
      content: TextField(
        controller: _text,
        autofocus: true,
        minLines: 3,
        maxLines: 5,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: InputDecoration(
          hintText: l10n.syncEnterCodeHint,
          errorText: _error,
          errorMaxLines: 3,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.syncJoinAction)),
      ],
    );
  }
}
